package AnnoTree::Model::Tree;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;
use Digest::SHA qw(sha256_hex);
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP ();
use Email::Simple ();
use Email::Simple::Creator ();
use Time::Piece ();

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
=begin usercode
    $json->{users} = [];
    my $userResult = AnnoTree::Model::MySQL->db->execute(
        'call get_users_by_tree(:userid, :treeid)',
        {
            userid      => $params->{userid},
            treeid      => $params->{treeid}
        }
    );

    my $userCols = $userResult->fetch;
    my $userCount = 0;
    while (my $user = $userResult->fetch) {
        for (my $i = 0; $i < @{$userCols}; $i++) {
            $json->{users}->[$userCount]->{$userCols->[$i]} = $user->[$i];
        }
        $userCount++;
    }
=end usercode
=cut
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
    #print Dumper($branches);
    #print Dumper($branchHolder);
=begin oldcode
    my $branchIndex = 0;
    while (my $branch = $branchResult->fetch) {
        for (my $i = 0; $i < @{$cols}; $i++) {
            $json->{branches}->[$branchIndex]->{$cols->[$i]} = $branch->[$i];
        }
        $json->{branches}->[$branchIndex]->{leaves} = [];
        my $leafResult = AnnoTree::Model::MySQL->db->execute(
            "call get_leafs(:branchid)",
            {
                branchid => $branch->[0]
            }
        );
        my $leafCols = $leafResult->fetch;
        my $leafIndex = 0;
        while (my $leaf = $leafResult->fetch) {
            for (my $i = 0; $i < @{$leafCols}; $i++) {
                $json->{branches}->[$branchIndex]->{leaves}->[$leafIndex]->{$leafCols->[$i]} = $leaf->[$i]; 
            }
            $json->{branches}->[$branchIndex]->{leaves}->[$leafIndex]->{annotations} = [];
            my $annoResult = AnnoTree::Model::MySQL->db->execute(
                'call get_annotation(:leafid)',
                {
                    leafid => $leaf->[0]
                }
            );
            my $annoCols = $annoResult->fetch;
            unless (looks_like_number($annoCols->[0])) {
                my $annoIndex = 0;
                while (my $anno = $annoResult->fetch) {
                    for (my $i = 0; $i < @{$annoCols}; $i++) {
                        $json->{branches}->[$branchIndex]->{leaves}->[$leafIndex]->{annotations}->[$annoIndex]->{$annoCols->[$i]} = $anno->[$i]; 
                    }
                    $annoIndex++;
                }
            }

            $leafIndex++;
        }
        $branchIndex++;
    }
=end oldcode
=cut
    return $json;
}

sub update {
    my ($class, $params) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call update_tree(:treeid, :name, :desc, :reqUser)",
        {
            treeid          => $params->{treeid},
            name            => $params->{name},
            desc            => $params->{desc},
            reqUser         => $params->{reqUser}
        }
    );

    my $json = {};
    my $num = $result->fetch->[0];
   
    if ($num == 0) {
        $json = {result => $num, txt => 'Task updated successfully'};
    } elsif ($num == 1) {
        $json = {result => $num, txt => 'Nothing was changed'};
    } elsif ($num == 2) {
        $json = {error => $num, txt => 'Task does not exist'};
    } elsif ($num == 3) {
        $json = {error => $num, txt => 'Requesting user does not exist or does not have access to the tree'};
    }

    return $json;
}

sub addUserToTree {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call add_user_to_tree(:treeid, :userToAdd, :requestingUser)",
        {
            userToAdd       => $params->{userToAdd},
            treeid          => $params->{treeid},
            requestingUser  => $params->{requestingUser}
        }
    ); 
    my $json = {};
    my $cols = $result->fetch;
    if (looks_like_number($cols->[0])) {
        my $num = $cols->[0];
        if ($num == 0) {
            $json = {error => $num, txt => $params->{userToAdd} . ' has already been added to this tree'};
        } elsif ($num == 1) {
            $json = {error => $num, txt => 'Tree does not exist or user does not have access to that tree'};
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
        $json->{id} = $userInfo->[0];
        my $subject = '';
        if ($status == 3) {
            $subject = "You've Been Invited To A Tree";
            $json->{firstName} = $userInfo->[1];
            $json->{lastName} = $userInfo->[2];
            $body = 'Hi ';
            $body .= $json->{firstName} || $json->{lastName};
            $body .= ",<br/><br/>";
            $body .= $curUserInfo->[0] || '';
            $body .= ' ' if $curUserInfo->[0];
            $body .= $curUserInfo->[1];
            $body .= ' has invited you to the ' . $curUserInfo->[2] . " tree.<br/><br/>";
            $body .= 'Go to <a href="https://ccp.annotree.com">https://ccp.annotree.com</a> to view this tree.' . "<br/>";
        } else {
            $subject = "You've Been Invited To Join AnnoTree";
            $json->{firstName} = '';
            $json->{lastName} = '';
            $body = 'Hi,' . "<br/><br/>";
            $body .= $curUserInfo->[0] || '';
            $body .= ' ' if $curUserInfo->[0];
            $body .= $curUserInfo->[1];
            $body .= ' has invited you to the ' . $curUserInfo->[2] . " tree.<br/><br/>";
            $body .= 'Go to <a href="https://ccp.annotree.com/#/authenticate/signUp">https://ccp.annotree.com/#/authenticate/signUp</a> to get started.' . "<br/>";
        }


        my $to = $params->{userToAdd};
        my $from = '"AnnoTree" <invite@annotree.com>';
        AnnoTree::Model::Email->mail($to, $from, $subject, $body);
    }
    
    return $json;
}

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
        $json = {error => $num, txt => 'Tree does not exist or user does not have permissions to delete tree'};
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
