package AnnoTree::Model::Branch;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);
use Config::General;

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;
my $path = $config{server}->{'annotationpath'};

my $getLeavesOnBranchCols = ['id', 'name', 'created_at', 'branch_id', 'priority', 'annotation'];

sub create {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_branch(:userid, :treeid, :name)",
        {
            userid      => $params->{userid},
            treeid      => $params->{treeid},
            name        => $params->{name},
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'You do not have permissions to create a branch on this tree'};
        } 
    }
    my $branchInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $branchInfo->[$i];
    }
    
    $json->{sub_branches} = [];
    if ($params->{type} eq 'tasks') {
        my $result = AnnoTree::Model::MySQL->db->execute(
            "call create_sub_branches(:branchid, :treeid)",
            {
                branchid    => $json->{id},
                treeid      => $params->{treeid},
            }
        );
        $cols = $result->fetch;
        my $subIndex = 0;
        while (my $sub = $result->fetch) {
            for (my $i = 0; $i < @{$cols}; $i++) {
                $json->{sub_branches}->[$subIndex]->{$cols->[$i]} = $sub->[$i];
            }
            $subIndex++;
        }
    }
    
    return $json;
}

sub info {
    my ($class, $params) = @_;

    my $leaves = AnnoTree::Model::MySQL->db->execute(
        "call get_leaves_on_branch(:userid, :treeid, :branchid)",
        {
            userid      => $params->{userid},
            treeid      => $params->{treeid},
            branchid    => $params->{branchid},
        }
    );

    my $json = {leaves => []};
    my $cols = $getLeavesOnBranchCols; #$leaves->fetch;
    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Can\'t create a branch with a user that is not active'};
        }
    }
    my $leavesIndex = 0;
    while (my $leaf = $leaves->fetch) {
        for (my $i = 0; $i < @{$cols}; $i++) {
            if ($cols->[$i] eq 'priority') {
                $json->{leaves}->[$leavesIndex]->{$cols->[$i]} = $leaf->[$i] + 0;
            } else {
                $json->{leaves}->[$leavesIndex]->{$cols->[$i]} = $leaf->[$i];
            }
        }
        $leavesIndex++;
    }
    return $json;
}

sub parentInfo {
    my ($class, $params) = @_;
    
    my $json = {};
    my $branches = AnnoTree::Model::MySQL->db->execute(
        "call get_sub_branches(:userid, :branchid)",
        {
            userid      => $params->{userid},
            branchid    => $params->{branchid},
        }
    );

    my $branchCols = $branches->fetch;
    if (looks_like_number($branchCols->[0])) { 
        my $error = $branchCols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'You do not have permissions to access this branch'};
        }
    }
    
    my $branchesIndex = 0;
    while (my $branch = $branches->fetch) {
        for (my $i = 0; $i < @{$branchCols}; $i++) {
            $json->{branches}->[$branchesIndex]->{$branchCols->[$i]} = $branch->[$i];
        }
 
        my $leaves = AnnoTree::Model::MySQL->db->execute(
            "call get_leaves_on_branch(:userid, :treeid, :branchid)",
            {
                userid      => $params->{userid},
                treeid      => $params->{treeid},
                branchid    => $json->{branches}->[$branchesIndex]->{id},
            }
        );
        
        my $cols = $getLeavesOnBranchCols; #$leaves->fetch;
        if (looks_like_number($cols->[0])) { 
            my $error = $cols->[0];
            if ($error == 1) {
                return {error => $error, txt => 'You do not have permissions to access this branch'};
            }
        }
        my $leavesIndex = 0;
        $json->{branches}->[$branchesIndex]->{leaves} = [];
        while (my $leaf = $leaves->fetch) {
            for (my $i = 0; $i < @{$cols}; $i++) {
                if ($cols->[$i] eq 'priority') {
                    $json->{branches}->[$branchesIndex]->{leaves}->[$leavesIndex]->{$cols->[$i]} = $leaf->[$i] + 0; 
                } else {
                    $json->{branches}->[$branchesIndex]->{leaves}->[$leavesIndex]->{$cols->[$i]} = $leaf->[$i];
                }
            }

            $json->{branches}->[$branchesIndex]->{leaves}->[$leavesIndex]->{assigned} = [];
            my $assignedIndex = 0;
            my $assignedResult = AnnoTree::Model::MySQL->db->execute(
                'call get_assigned_leaf_users(:leafid)',
                {
                    leafid => $leaf->[0]
                }
            );
            my $assignedCols = $assignedResult->fetch;
            while (my $assign = $assignedResult->fetch) {
                for (my $i = 0; $i < @{$assignedCols}; $i++) {
                    $json->{branches}->[$branchesIndex]->{leaves}->[$leavesIndex]->{assigned}->[$assignedIndex]->{$assignedCols->[$i]} = $assign->[$i];
                }
                $assignedIndex++;
            }
       
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
                        $json->{branches}->[$branchesIndex]->{leaves}->[$leavesIndex]->{annotations}->[$annoIndex]->{$annoCols->[$i]} = $anno->[$i]; 
                    }
                    $annoIndex++;
                }
            }
            $leavesIndex++;
        }
        $branchesIndex++;
    }

    return $json;
}

sub rename {
    my ($class, $params) = @_;

    my $json = {};
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call rename_branch(:userid, :treeid, :branchid, :name)",
        {
            userid      => $params->{userid},
            treeid      => $params->{treeid},
            branchid    => $params->{branchid},
            name        => $params->{name},
        }
    );

    my $status = $result->fetch->[0];
    if ($status == 0) {
        $json = {result => $status, txt => 'Branched renamed'};
    } elsif ($status == 1) {
        $json = {result => $status, txt => 'You do not have permission to rename that branch'};
    }

    return $json;
}

sub delete {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call delete_branch(:reqUser, :treeid, :branchid)",
        {
            reqUser         => $params->{userid},
            treeid          => $params->{treeid},
            branchid        => $params->{branchid},
        }
    );
    
    my $json = {};
    my $num = $result->fetch->[0];
    if (looks_like_number($num)) {
       if ($num == 1) {
            $json = {error => $num, txt => 'You do not have permission to delete this branch'};
        } elsif ($num == 2) {
            $json = {error => $num, txt => 'You can\'t delete the User Feedback branch'};
        } 
    } else {
        while (my $filename = $result->fetch) {
            `rm -rf $path/$json->{forestid}/$filename->[0]`;
        }   
    }

    return $json;
}

return 1;
