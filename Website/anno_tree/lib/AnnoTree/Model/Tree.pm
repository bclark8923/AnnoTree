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

sub create {
    my ($class, $params) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_tree(:userid, :forestid, :name, :desc, :logo)",
        {
            userid      => $params->{userid},
            forestid    => $params->{forestid},
            name        => $params->{name},
            desc        => $params->{desc},
            logo        => $params->{logo}
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    if (looks_like_number($cols->[0])) { 
        # returns a 1 if user does not exist or was deleted
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Can\'t create a tree with a user that does not exist or was deleted'};
        } elsif ($error == 2) {
            return {error => $error, txt => 'Forest does not exist'};
        } elsif ($error == 3) {
            return {error => $error, txt => 'User does not have permissions to create a tree in this forest'};
        } 
    }
    my $treeInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $treeInfo->[$i];
    }
    
    my $token = sha256_hex($treeInfo->[0]);
    my $tokenResult = AnnoTree::Model::MySQL->db->execute(
        "call add_tree_token(:token, :treeid)",
        {
            token   => $token,
            treeid  => $treeInfo->[0]
        }
    );
    $json->{token} = $token;
    
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
        $json->{$cols->[$i]} = $treeInfo->[$i];
    }
    
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

    $json->{branches} = [];
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
            return {error => $error, txt => 'Tree does not exist or user does not have access to that tree'};
        }
    }
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
=begin oldcode
    $result = AnnoTree::Model::MySQL->db->execute(
        "call get_branches_and_leafs(:userid, :treeid)",
        {
            userid      => $params->{userid},
            treeid      => $params->{treeid}
        }
    ); 
    $cols = $result->fetch;
    return $json unless defined $cols->[0];
    my @tempCols = grep(m/branch/, @{$cols});
    my @branchCols;
    while (@tempCols) {
        my $temp = shift @tempCols;
        ($temp) = $temp =~ m/branch (\w+)/;
        push @branchCols, $temp;
    }
    my @leafCols;
    @tempCols = grep(m/leaf/, @{$cols});
    while (@tempCols) {
        my $temp = shift @tempCols;
        ($temp) = $temp =~ m/leaf (\w+)/;
        push @leafCols, $temp;
    }
    my $index;
    my $numBranches = 0;
    while (my $return = $result->fetch) {
        my $foundBranch = -1;
        for (my $i = 0; $i < @{$json->{branches}}; $i++) {
            next unless $json->{branches}->[$i]->{id} == $return->[0];
            print 'found branch';
            $foundBranch = $i;
        }
        if ($foundBranch == -1) {
            for (my $i = 0; $i < @branchCols; $i++) {
                $json->{branches}->[$numBranches]->{$branchCols[$i]} = $return->[$i];
            }
        }
        my $branchSpot = ($foundBranch == -1 ? $numBranches : $foundBranch);
        $json->{branches}->[$branchSpot]->{leaves} = [] unless exists $json->{branches}->[$branchSpot]->{leaves};
        my $leafCount = @{$json->{branches}->[$branchSpot]->{leaves}};
        for (my $i = 0; $i < @leafCols; $i++) {
            $json->{branches}->[$branchSpot]->{leaves}->[$leafCount]->{$leafCols[$i]} = $return->[$i + @branchCols];
        }
        $numBranches++;
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
    #print Dumper($cols);
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
            $json = {result => $num, txt => 'User added successfully'};
        } elsif ($num == 1) {
            $json = {error => $num, txt => 'Tree does not exist or user does not have access to that tree'};
        } elsif ($num == 2) {
            $json = {error => $num, txt => 'User you tried to add does not exist'};
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
            $subject = 'You\'ve Been Invited To Another Tree';
            $json->{firstName} = $userInfo->[1];
            $json->{lastName} = $userInfo->[2];
            $body = 'Hi ';
            $body .= $json->{firstName} || $json->{lastName};
            $body .= ",\n\n";
            $body .= $curUserInfo->[0] || '';
            $body .= ' ' if $curUserInfo->[0];
            $body .= $curUserInfo->[1];
            $body = ' has invited you to the ' . $curUserInfo->[2] . " tree.\n\n";
            $body .= 'Go to http://annotree.com/login to view this tree.' . "\n";
        } else {
            $subject = 'You\'ve Been Invited To Join AnnoTree';
            $json->{firstName} = '';
            $json->{lastName} = '';
            $body = 'Hi,';
            $body .= $curUserInfo->[0] || '';
            $body .= ' ' if $curUserInfo->[0];
            $body .= $curUserInfo->[1];
            $body = ' has invited you to the ' . $curUserInfo->[2] . " tree.\n\n";
            $body .= 'Go to http://annotree.com/signup to get started.' . "\n";
        }
        $body .= "\n" . '-AnnoTree' . "\n";

        my $smtpserver = 'smtp.mailgun.org';
        my $smtpport = 587;
        my $smtpuser   = 'postmaster@annotree.com';
        my $smtppassword = '8-7sigqno8u7';

        my $transport = Email::Sender::Transport::SMTP->new({
          host => $smtpserver,
          port => $smtpport,
          sasl_username => $smtpuser,
          sasl_password => $smtppassword,
        });

        my $email = Email::Simple->create(
          header => [
            To      => $params->{userToAdd},
            From    => 'invite@annotree.com',
            Subject => $subject,
          ],
          body => $body
        );

        sendmail($email, { transport => $transport });
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
        $json = {result => $num, txt => 'Tree deleted successfully'};
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
    }
 

    return $json;
}

return 1;
