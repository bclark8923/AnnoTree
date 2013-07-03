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
    my ($class, $params) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call get_tasks_by_tree(:userid, :treeid)",
        {
            treeid  => $params->{treeid},
            userid  => $params->{userid}
        }
    );

    my $json = {};
    my $cols = $result->fetch;

    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Tree does not exist or user does not have access to that tree'};
        }
    }
    my $taskIndex = 0;
    $json->{tasks} = [];
    while (my $task = $result->fetch) {
        for (my $i = 0; $i < @{$cols}; $i++) {
            $json->{tasks}->[$taskIndex]->{$cols->[$i]} = $task->[$i] || '';
        }
        $taskIndex++;
    }
    
    return $json;
}

sub updateTask {
    my ($class, $params) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call update_task(:taskid, :desc, :status, :leafid, :assignedTo, :dueDate, :requestingUser)",
        {
            taskid          => $params->{taskid},
            desc            => $params->{desc},
            status          => $params->{status},
            leafid          => $params->{leafid},
            assignedTo      => $params->{assignedTo},
            dueDate         => $params->{dueDate},
            requestingUser  => $params->{requestingUser}
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
    } elsif ($num == 4) {
        $json = {error => $num, txt => 'Task status does not exist'};
    } elsif ($num == 5) {
        $json = {error => $num, txt => 'The person you tried to assign the task to does not exist or does not have access to that tree'};
    } elsif ($num == 6) {
        $json = {error => $num, txt => 'Leaf does not exist'};
    }
    
    return $json;
}

return 1;
