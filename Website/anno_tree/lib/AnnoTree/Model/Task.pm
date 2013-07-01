package AnnoTree::Model::Task;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;

sub create {
    my ($class, $params) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_task(:desc, :status, :leafid, :treeid, :assignedTo, :dueDate, :createdBy)",
        {
            desc        => $params->{desc},
            status      => $params->{status},
            leafid      => $params->{leafid},
            treeid      => $params->{treeid},
            assignedTo  => $params->{assignedTo},
            dueDate     => $params->{dueDate},
            createdBy   => $params->{createdBy}
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    print Dumper($cols);
    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Tree does not exist or user does not have access to that tree'};
        } elsif ($error == 2) { 
            return {error => $error, txt => 'Invalid status'};
        } 
    }
    my $taskInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $taskInfo->[$i] || '';
    }
    
    return $json;
}

sub treeTaskInfo {

}

return 1;
