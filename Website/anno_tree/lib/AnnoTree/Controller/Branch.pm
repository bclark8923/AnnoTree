package AnnoTree::Controller::Branch;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::Branch;

# creates a new branch
sub create {
    my $self = shift;
    
    my $jsonReq = $self->req->json;
    $self->render(json => {error => '0', txt => 'Please enter a branch name'}, status => 406) and return unless (exists $jsonReq->{name}); 
    $self->render(json => {error => '4', txt => 'Please select a valid branch type. Valid types are grid or tasks.'}, status => 406) and return 
        unless (exists $jsonReq->{type} && ($jsonReq->{type} eq 'grid' || $jsonReq->{type} eq 'tasks')); 
    
    my $params = {};
    $params->{treeid} = $self->param('treeid');
    $params->{userid} = $self->current_user->{userid};
    $params->{name} = $jsonReq->{name};
    $params->{type} = $jsonReq->{type};
    $self->render(json => {error => '5', txt => 'A branch name must include at least one alphanumeric character'}, status => 406) and return unless ($params->{name} =~ m/[A-Za-z0-9]/);

    my $json = AnnoTree::Model::Branch->create($params);
    my $status = 200;
    $status = 406 if (exists $json->{error});
    
    $self->render(json => $json, status => $status); 
}

sub info {
    my $self = shift;

    my $params = {};
    $params->{treeid} = $self->param('treeid');
    $params->{branchid} = $self->param('branchid');
    $params->{userid} = $self->current_user->{userid};

    my $json = AnnoTree::Model::Branch->info($params);
    my $status = 200;
    $status = 406 if (exists $json->{error});
    
    $self->render(json => $json, status => $status);
}

sub parentInfo {
    my $self = shift;

    my $params = {};
    $params->{treeid} = $self->param('treeid');
    $params->{branchid} = $self->param('branchid');
    $params->{userid} = $self->current_user->{userid};

    my $json = AnnoTree::Model::Branch->parentInfo($params);
    my $status = 200;
    $status = 406 if (exists $json->{error});
    
    $self->render(json => $json, status => $status);
}

return 1;
