package AnnoTree::Model::Forest;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;

# Create a new forest 
sub create {
    my ($class, $params) = @_;
    
    #print Dumper($params);
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_forest(:userid, :name, :desc)",
        {
            userid  => $params->{userid},
            name    => $params->{name},
            desc    => $params->{desc}
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    if (looks_like_number($cols->[0])) { 
        # returns a 1 if user does not exist or was deleted
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Can\'t create a forest with a user that does not exist or was deleted'};
        }
    }
    my $forestInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $forestInfo->[$i];
    }
    
    return $json;
}

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
    
    return {error => $cols->[0], txt => 'Can\'t retrieve forests for a user that does not exist or was deleted'} if (looks_like_number($cols->[0])); # returns a 1 if user does not exist or was deleted
    
    while (my $forest = $result->fetch) {
        for (my $i = 0; $i < @{$cols}; $i++) {
            $json->{forests}->[$forestCount]->{$cols->[$i]} = $forest->[$i];
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
            desc            => $params->{desc},
            reqUser         => $params->{reqUser}
        }
    );

    my $json = {};
    my $num = $result->fetch->[0];
    #print Dumper($cols);
    if ($num == 0) {
        $json = {result => $num, txt => 'Forest updated successfully'};
    } elsif ($num == 1) {
        $json = {result => $num, txt => 'Nothing was changed'};
    } elsif ($num == 2) {
        $json = {error => $num, txt => 'Forest does not exist or user does not have permissions to that forest'};
    }
    
    return $json; 
}

return 1;
