package AnnoTree::Controller::Leaf;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::Leaf;

# creates a new leaf
sub create {
    my $self = shift;
    
    my $jsonReq = $self->req->json;
    $self->debug($self->dumper($jsonReq));
    $self->render(json => {error => '0', txt => 'Missing JSON name/value pairs in request'}, status => 406) and return unless (exists $jsonReq->{name} && exists $jsonReq->{description}); 
    
    my $params = {};
    $params->{branchid} = $self->param('branchid');
    $params->{userid} = $self->current_user->{userid};
    $params->{name} = $jsonReq->{name};
    $params->{desc} = $jsonReq->{description};
    $self->render(json => {error => '4', txt => 'No name for the leaf provided - include at least one alphanumeric character'}, status => 406) and return unless ($params->{name} =~ m/[A-Za-z0-9]/);

    my $json = AnnoTree::Model::Leaf->create($params);
    my $status = 200;
    if (exists $json->{error}) {
        my $error = $json->{error};
        if ($error == 1 || $error == 2) { # user does not exist or was deleted, branch does not exist
           $status = 406;
        }
    }
    $self->render(json => $json, status => $status); 
}

return 1;