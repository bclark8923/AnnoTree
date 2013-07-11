package AnnoTree::Controller::Task;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::Task;

sub create {
    my $self = shift;
    
    my $jsonReq = $self->req->json;

    $self->render(json => {error => '0', txt => 'Missing required JSON name/value pairs in request or they have no value'}, status => 406) and return unless ($jsonReq->{'description'} && $jsonReq->{'status'} && $jsonReq->{'treeid'});
    $self->render(json => {error => '3', txt => 'Task description must contain at least one alphanumeric character'}, status => 406) and return unless ($jsonReq->{'description'} =~ m/[A-Za-z0-9]/);

    my $params = {};
    $params->{desc} = $jsonReq->{'description'};
    $params->{createdBy} = $self->current_user->{userid};
    $params->{status} = $jsonReq->{'status'};
    $params->{leafid} = $jsonReq->{'leafid'} || undef;
    $params->{treeid} = $jsonReq->{'treeid'};
    $params->{assignedTo} = $jsonReq->{'assignedTo'} || undef;
    $params->{dueDate} = $jsonReq->{'dueDate'} || undef;

    my $json = AnnoTree::Model::Task->create($params);
    my $status = 200;
    if (exists $json->{error}) {
       $status = 406;
    }
    $self->render(json => $json, status => $status);
}

sub treeTaskInfo {
    my $self = shift;

    my $params = {};
    $params->{userid} = $self->current_user->{userid};
    $params->{treeid} = $self->param('treeid');
    my $json = AnnoTree::Model::Task->treeTaskInfo($params);
    my $status = 200;
    if (exists $json->{error}) {
       $status = 406;
    }
    $self->render(json => $json, status => $status); 
}

sub updateTask {
    my $self = shift;
    my $jsonReq = $self->req->json;

    $self->render(json => {error => '0', txt => 'Missing required JSON name/value pairs in request or they have no value'}, status => 406) and return unless ($jsonReq->{'description'} && $jsonReq->{'status'} && exists $jsonReq->{'leafid'} && exists $jsonReq->{'assignedTo'} && exists $jsonReq->{'dueDate'});
    $self->render(json => {error => '1', txt => 'Task description must contain at least one alphanumeric character'}, status => 406) and return unless ($jsonReq->{'description'} =~ m/[A-Za-z0-9]/);

    my $params = {};
    $params->{taskid} = $self->param('taskid');
    $params->{desc} = $jsonReq->{'description'};
    $params->{requestingUser} = $self->current_user->{userid};
    $params->{status} = $jsonReq->{'status'};
    $params->{leafid} = $jsonReq->{'leafid'} || undef;
    $params->{assignedTo} = $jsonReq->{'assignedTo'} || undef;
    $params->{dueDate} = $jsonReq->{'dueDate'} || undef;

    my $json = AnnoTree::Model::Task->updateTask($params);
    my $status = 204;
    if (exists $json->{error}) {
       $status = 406;
    }
    $self->render(json => $json, status => $status);
}

sub deleteTask {
    my $self = shift;

    my $params = {};
    $params->{reqUser} = $self->current_user->{userid};
    $params->{taskid} = $self->param('taskid');
    
    my $json = AnnoTree::Model::Task->deleteTask($params);
    
    my $status = 204;
    if (exists $json->{error}) {
        $status = 406;
    }

    $self->render(json => $json, status => $status);
}

return 1;
