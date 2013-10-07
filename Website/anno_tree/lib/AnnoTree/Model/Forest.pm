package AnnoTree::Model::Forest;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;

# Create a new forest 
sub create {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_forest(:userid, :name, :desc)",
        {
            userid  => $params->{userid},
            name    => $params->{name},
            desc    => undef
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    if (looks_like_number($cols->[0])) { 
        # returns a 1 if user does not exist or was deleted
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'There seems to be an internal error within our system.  Your user account may have been deleted.  Please contact us at support@annotree.com.'};
        }
    }
    my $forestInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $forestInfo->[$i];
    }
    
    return $json;
}

# TODO: simplify and combine these procedures
sub forestInfo {
    my ($class, $userid) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call get_forest_by_user(:userid)",
        {
            userid => $userid
        }
    );

    my $json = {};
    my $forestCount = 0;
    my $cols = $result->fetch;
    
    return {error => $cols->[0], txt => 'There seems to be an internal error within our system.  Your user account may have been deleted.  Please contact us at support@annotree.com.'} if (looks_like_number($cols->[0])); # returns a 1 if user does not exist or was deleted
    
    while (my $forest = $result->fetch) {
        for (my $i = 0; $i < @{$cols}; $i++) {
            if ($cols->[$i] =~ m/owner_(.*)/) {
                $json->{forests}->[$forestCount]->{owner}->{$1} = $forest->[$i];
            } else {
                $json->{forests}->[$forestCount]->{$cols->[$i]} = $forest->[$i];
            }
        }
        
        my $treeResult = AnnoTree::Model::MySQL->db->execute(
            'call get_trees_by_user_by_forest(:userid, :forestid)',
            {
                userid      => $userid,
                forestid    => $json->{forests}->[$forestCount]->{id}
            }
        );

        $json->{forests}->[$forestCount]->{trees} = [];
        my $treeCols = $treeResult->fetch;
        my $treeCount = 0;

        while (my $tree = $treeResult->fetch) {
            for (my $i = 0; $i < @{$treeCols}; $i++) {
                $json->{forests}->[$forestCount]->{trees}->[$treeCount]->{$treeCols->[$i]} = $tree->[$i];
            }
=begin usercode
            my $userResult = AnnoTree::Model::MySQL->db->execute(
                'call get_users_by_tree(:userid, :treeid)',
                {
                    userid      => $userid,
                    treeid      => $tree->[0]
                }
            );

            $json->{forests}->[$forestCount]->{trees}->[$treeCount]->{users} = [];
            my $userCols = $userResult->fetch;
            my $userCount = 0;
            while (my $user = $userResult->fetch) {
                for (my $i = 0; $i < @{$userCols}; $i++) {
                    $json->{forests}->[$forestCount]->{trees}->[$treeCount]->{users}->[$userCount]->{$userCols->[$i]} = $user->[$i];
                }
                $userCount++;
            }
=end usercode
=cut
            $treeCount++;
        }
        $forestCount++;
    }
    
    return {error => 2, txt => 'No forests exist for this user'} if ($forestCount == 0); # return a one if there are no forests the user belongs to

    return $json;
}

sub update {
    my ($class, $params) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call update_forest(:forestid, :name, :desc, :reqUser)",
        {
            forestid        => $params->{forestid},
            name            => $params->{name},
            desc            => undef,
            reqUser         => $params->{reqUser}
        }
    );

    my $json = {};
    my $num = $result->fetch->[0];
    
    if ($num == 0) {
        $json = {result => $num, txt => 'Forest updated successfully'};
    } elsif ($num == 1) {
        $json = {result => $num, txt => 'Nothing was changed'};
    } elsif ($num == 2) {
        $json = {error => $num, txt => 'Forest does not exist or you do not have permissions to that forest'};
    }
    
    return $json; 
}

# TODO: can this be deleted?
sub getForestAnnotations {
    my ($class, $params) = @_;

    my $annoResult = AnnoTree::Model::MySQL->db->execute(
        "call get_annotations_by_forest(:reqUser, :forestid)",
        {
            reqUser     => $params->{reqUser},
            forestid    => $params->{forestid}
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

sub deleteForest {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call delete_forest(:reqUser, :forestid)",
        {
            forestid        => $params->{forestid},
            reqUser         => $params->{reqUser}
        }
    );

    my $json = {};
    my $num = $result->fetch->[0];
    if ($num == 0) {
        $json = {result => $num, txt => 'Forest deleted successfully'};
    } elsif ($num == 1) {
        $json = {error => $num, txt => 'Forest does not exist or you do not have permission to delete forest'};
    } elsif ($num == 2) {
        $json = {error => $num, txt => 'Only the forest owner may delete this forest'};
    } 

    return $json;
}

sub forestUsers {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call get_forest_users(:forestid, :userid)",
        {
            forestid    => $params->{forestid},
            userid      => $params->{userid}
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    return {error => $cols->[0], txt => 'You do not have permissions to access that forest'} if (looks_like_number($cols->[0]));
    
    my $userCount = 0;
    while (my $user = $result->fetch) {
        for (my $i = 0; $i < @{$cols}; $i++) {
            $json->{users}->[$userCount]->{$cols->[$i]} = $user->[$i] || '';
        }
        $userCount++;
    }

    return $json;
}

sub updateOwner {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call update_forest_owner(:forestid, :reqUser, :newOwner)",
        {
            forestid    => $params->{forestid},
            reqUser     => $params->{reqUser},
            newOwner    => $params->{newOwner}
        }
    );

    my $cols = $result->fetch;
    if (looks_like_number($cols->[0])) {
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Selected user does not have permissions to access that forest or forest does not exist'};
        } elsif ($error == 2) {
            return {error => $error, txt => 'Selected user does not have permissions to own that forest'};
        } elsif ($error == 3) {
            return {error => $error, txt => 'Selected user is already the owner of that forest'};
            
        }
    }
    
    my $json = {};
    my $ownerInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $ownerInfo->[$i];
    } 

    return $json;
}

return 1;
