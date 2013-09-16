package AnnoTree::Model::Branch;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;

my $getLeavesOnBranchCols = ['id', 'name', 'created_at', 'branch_id', 'priority', 'annotation'];

sub create {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_branch(:userid, :treeid, :name, :desc)",
        {
            userid      => $params->{userid},
            treeid      => $params->{treeid},
            name        => $params->{name},
            desc        => $params->{desc},
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Can\'t create a branch with a user that is not active'};
        } elsif ($error == 2) { 
            return {error => $error, txt => 'Tree does not exist'};
        } 
    }
    my $branchInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $branchInfo->[$i];
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
=begin annotationcode 
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
                    $json->{leaves}->[$leavesIndex]->{annotations}->[$annoIndex]->{$annoCols->[$i]} = $anno->[$i]; 
                }
                $annoIndex++;
            }
        }
=end annotationcode
=cut
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

return 1;
