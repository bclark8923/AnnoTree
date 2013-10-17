package AnnoTree::Model::Tree;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use AnnoTree::Model::Email;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;
use Digest::SHA qw(sha256_hex);
use Config::General;
use Time::Piece ();
use Gravatar::URL;

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;
my $confCCP = $config{server}->{base_url};
my $confSplash = $config{server}->{splash_url};

sub create {
    my ($class, $params) = @_;

    my $created = Time::Piece::localtime->strftime('%F %T');  
    
    my $token = sha256_hex($params->{forestid}, $params->{userid}, $created, int(rand(1000000000)));
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_tree(:userid, :forestid, :name, :desc, :logo, :token, :created)",
        {
            userid      => $params->{userid},
            forestid    => $params->{forestid},
            name        => $params->{name},
            desc        => undef,
            logo        => $params->{logo},
            token       => $token,
            created     => $created
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'There seems to be an internal error within our system.  Your user account may have been deleted.  Please contact us at support@annotree.com.'};
        } elsif ($error == 2) {
            return {error => $error, txt => 'Forest does not exist'};
        } elsif ($error == 3) {
            return {error => $error, txt => 'You do not have permissions to create a tree in this forest'};
        } 
    }
    my $treeInfo = $result->fetch;
    my $treeID;
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $treeInfo->[$i];
        if ($cols->[$i] eq 'id') {
            $treeID = $treeInfo->[$i];
        }
    }
    print $treeID;
    my $branchResult = AnnoTree::Model::MySQL->db->execute(
        "call create_default_branches(:userid, :treeid)",
        {
            userid      => $params->{userid},
            treeid      => $treeID
        }
    );
    my $branchStatus = $branchResult->fetch->[0];
    if ($branchStatus == 1 || $branchStatus == 2) {
        AnnoTree::Model::MySQL->db->execute(
            "call delete_tree(:reqUser, :treeid)",
            {
                treeid          => $treeID,
                reqUser         => $params->{userid}
            }
        );
        return {error => "5", txt => 'There seems to be an internal error within our system.  Try to create the tree again or contact us at support@annotree.com.'};
    }

    return $json;
}

sub treeInfo {
    my ($class, $params) = @_;
    
    my $json = {};
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call get_tree(:userid, :treeid)",
        {
            userid  => $params->{userid},
            treeid  => $params->{treeid}
        }
    ); 
    my $cols = $result->fetch;
    if (looks_like_number($cols->[0])) {
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Tree does not exist or user does not have access to that tree'};
        } 
    }
    my $treeInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        if ($cols->[$i] =~ m/forest_owner_(.*)/) {
            $json->{forest_owner}->{$1} = $treeInfo->[$i];
        } else {
            $json->{$cols->[$i]} = $treeInfo->[$i];
        }
    }

    $result = AnnoTree::Model::MySQL->db->execute(
        "call get_users_by_tree(:reqUser, :treeid)",
        {
            treeid          => $params->{treeid},
            reqUser         => $params->{userid}
        }
    );
    
    $cols = $result->fetch;
    my $userIndex = 0;
    while (my $user = $result->fetch) {
        for (my $i = 0; $i < @{$cols}; $i++) {
            $json->{users}->[$userIndex]->{$cols->[$i]} = $user->[$i];
        }
        $userIndex++;
    }

    my $branchResult = AnnoTree::Model::MySQL->db->execute(
        "call get_branches(:userid, :treeid)",
        {
            userid      => $params->{userid},
            treeid      => $params->{treeid}
        }
    ); 
    $cols = $branchResult->fetch;
    if (looks_like_number($cols->[0])) {
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'You do not have permission to access to that tree'};
        }
    }
    my $branchHolder = {};
    my $branchHolderIndex = 0;
    my $branches = [];
    my $branchesIndex = 0;
    while (my $branch = $branchResult->fetch) {
        my $tempBranch;
        for (my $i = 0; $i < @{$cols}; $i++) {
            $tempBranch->{$cols->[$i]} = $branch->[$i];
        }
        if (defined $tempBranch->{parent_branch}) {
            push @{$branchHolder->{$tempBranch->{parent_branch}}}, $tempBranch;
        } else {
            delete $tempBranch->{priority};
            delete $tempBranch->{parent_branch};
            $tempBranch->{sub_branches} = [];
            $branches->[$branchesIndex] = $tempBranch;
            $branchesIndex++;
        }
    }
    for (my $i = 0; $i < @{$branches}; $i++) {
        if (exists $branchHolder->{$branches->[$i]->{id}}) {
            $branches->[$i]->{sub_branches} = $branchHolder->{$branches->[$i]->{id}};
        }
    }
    $json->{branches} = $branches;

    return $json;
}

sub rename {
    my ($class, $params) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call rename_tree(:treeid, :name, :reqUser)",
        {
            treeid          => $params->{treeid},
            name            => $params->{name},
            reqUser         => $params->{reqUser}
        }
    );

    my $json = {};
    my $num = $result->fetch->[0];
   
    if ($num == 0) {
        $json = {result => $num, txt => 'Tree updated successfully'};
    } elsif ($num == 1) {
        $json = {error => $num, txt => 'You do not have permissions on that tree'};
    }

    return $json;
}

sub treeUsers {
   my ($class, $params) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call get_users_by_tree(:reqUser, :treeid)",
        {
            treeid          => $params->{treeid},
            reqUser         => $params->{reqUser}
        }
    );

    my $json = {};
    
    my $cols = $result->fetch;
    if (looks_like_number($cols->[0])) {
        my $num = $cols->[0];
        if ($num == 1) {
            $json = {error => $num, txt => 'You do not have permissions to access that tree'};
        } 
    }
    
    my $userIndex = 0;
    while (my $user = $result->fetch) {
        for (my $i = 0; $i < @{$cols}; $i++) {
            $json->{users}->[$userIndex]->{$cols->[$i]} = $user->[$i];
        }
        $userIndex++;
    }

    return $json;

}

sub addUserToTree {
    my ($class, $params) = @_;
   
    my %options = (
        default => 'wavatar', 
        rating  => 'pg',
        https   => 1
    );
 
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call add_user_to_tree(:treeid, :userToAdd, :requestingUser, :newUserImg)",
        {
            userToAdd       => $params->{userToAdd},
            treeid          => $params->{treeid},
            requestingUser  => $params->{requestingUser},
            newUserImg      => gravatar_url(email => $params->{userToAdd}, %options),
        }
    ); 

    my $json = {};
    my $cols = $result->fetch;
    if (looks_like_number($cols->[0])) {
        my $num = $cols->[0];
        if ($num == 0) {
            $json = {error => $num, txt => $params->{userToAdd} . ' has already been added to this tree'};
        } elsif ($num == 1) {
            $json = {error => $num, txt => 'You do not have permissions to access that tree'};
        }
    } else {
        my $status = $result->fetch->[0];
        $json->{$cols->[0]} = $status;
        my $body = ''; 
        my $curUser = AnnoTree::Model::MySQL->db->execute(
            "call get_user_name_tree_name(:userid, :treeid)",
            {
                userid      => $params->{requestingUser},
                treeid      => $params->{treeid}
            }
        );
        my $curUserInfo = $curUser->fetch;
        my $addedUser = AnnoTree::Model::MySQL->db->execute(
            "call get_user(:email)",
            {
                email => $params->{userToAdd}
            }
        );

        my $cols = $addedUser->fetch; # get the columns (keys for json)
        my $userInfo = $addedUser->fetch;
        for (my $i = 0; $i < @{$cols}; $i++) {
            $json->{$cols->[$i]} = $userInfo->[$i];
        }
        if ($userInfo->[9] == 1) {
            my $subject = '';
            if ($status == 3) {
                $subject = "You've Been Invited To A Tree";
                $body = 'Hi ';
                $body .= $json->{first_name} || $json->{last_name};
                $body .= ",<br/><br/>";
                $body .= $curUserInfo->[0] || '';
                $body .= ' ' if $curUserInfo->[0];
                $body .= $curUserInfo->[1];
                $body .= ' has invited you to ' . $curUserInfo->[2] . ".<br/><br/>";
                $body .= 'Go to <a href="' . $confCCP . '/#/app/' . $curUserInfo->[3] . '/' . $params->{treeid} . '">' . $confCCP . '/#/app/' . $curUserInfo->[3] . '/' . $params->{treeid} . '</a> to view this tree.';
            } else {
                $subject = "You've Been Invited To Join AnnoTree";
                $body = 'Hi,' . "<br/><br/>";
                $body .= $curUserInfo->[0] || '';
                $body .= ' ' if $curUserInfo->[0];
                $body .= $curUserInfo->[1];
                $body .= ' has invited you to collaborate with them through AnnoTree - a visual, design-focused collaboration tool for application development.<br/><br/>';
                $body .= 'To learn more about AnnoTree, visit <a href="' . $confSplash . '">' . $confSplash . '</a> or go to <a href="' . $confCCP . '/#/authenticate/signUp">' . $confCCP . '/#/authenticate/signUp</a> to create an account and beging collaborating and streamlining your development.';
            }

            my $to = $params->{userToAdd};
            my $from = '"AnnoTree" <invite@annotree.com>';
            AnnoTree::Model::Email->mail($to, $from, $subject, $body);
        }
    }
    
    return $json;
}

#TODO: is this used?
sub getTreeAnnotations {
    my ($class, $params) = @_;

    my $annoResult = AnnoTree::Model::MySQL->db->execute(
        "call get_annotations_by_tree(:reqUser, :treeid)",
        {
            reqUser     => $params->{reqUser},
            treeid      => $params->{treeid}
        }
    );
    my $annoPath = '';
    my @annos;
    while (my $return = $annoResult->fetch) {
        if (defined $return->[0]) {
            ($annoPath) = $return->[0] =~ m/.*\/(.+)$/;
            push(@annos, $annoPath) if $annoPath;
        }
    }
    
    return @annos;
}

sub deleteTree {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call delete_tree(:reqUser, :treeid)",
        {
            treeid          => $params->{treeid},
            reqUser         => $params->{reqUser}
        }
    );

    my $json = {};
    my $num = $result->fetch->[0];
    if ($num == 0) {
        $json = {result => $num, txt => 'Tree deleted successfully', forestid => $result->fetch->[0]};
    } elsif ($num == 1) {
        $json = {error => $num, txt => 'You do not have permission to delete this tree'};
    }

    return $json;
}

sub removeUserFromTree {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call delete_user_from_tree(:treeid, :rmUser, :reqUser)",
        {
            treeid          => $params->{treeid},
            rmUser          => $params->{rmUser},
            reqUser         => $params->{reqUser}
        }
    );

    my $json = {};
    my $num = $result->fetch->[0];
    if ($num == 0) {
        $json = {result => $num, txt => 'User was removed from tree successfully'};
    } elsif ($num == 1) {
        $json = {error => $num, txt => 'There was no user to remove'};
    } elsif ($num == 2) {
        $json = {error => $num, txt => 'Tree does not exist or user does not have permissions to remove that user from the tree'};
    } elsif ($num == 3) {
        $json = {error => $num, txt => 'You can\'t remove the forest owner from a tree'};
    }

    return $json;
}

sub iosTokens {
    my ($class, $tokens) = @_;

    my $json = {tokens => []};
    my $index = 0;
    for my $token (@{$tokens}) {
        my $result = AnnoTree::Model::MySQL->db->execute(
            "call get_tree_name_from_token(:token)",
            {
                token => $token
            }
        );
        my $return = $result->fetch;
        my $treeName = '';
        $treeName = $return->[0] if defined $return;
        $json->{tokens}->[$index] = {$token => $treeName};
        $index++;
    }

    return $json;
}

return 1;
