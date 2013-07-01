package AnnoTree::Controller::Task;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::Task;

sub create {
    my $self = shift;
    
    my $jsonReq = $self->req->json;
    $self->debug($self->dumper($jsonReq));
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
    #$self->debug($self->dumper($params));
    my $json = AnnoTree::Model::Task->create($params);
    my $status = 200;
    if (exists $json->{error}) {
       $status = 406;
    }
    $self->render(json => $json, status => $status);
}

sub treeTaskInfo {

}

return 1;
