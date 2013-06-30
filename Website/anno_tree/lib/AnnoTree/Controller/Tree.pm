package AnnoTree::Controller::Tree;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::Tree;

# creates a new tree
sub create {
    my $self = shift;
    
    my $jsonReq = $self->req->json;
    $self->render(json => {error => '0', txt => 'Missing JSON name/value pairs in request'}, status => 406) and return unless (exists $jsonReq->{name} && exists $jsonReq->{description}); 
    
    my $params = {};
    $params->{forestid} = $self->param('forestid');
    $params->{userid} = $self->current_user->{userid};
    $params->{name} = $jsonReq->{name};
    $params->{desc} = $jsonReq->{description};
    $params->{logo} = 'img/logo.png';
    $self->render(json => {error => '4', txt => 'No name for the tree provided - include at least one alphanumeric character'}, status => 406) and return unless ($params->{name} =~ m/[A-Za-z0-9]/);

    my $json = AnnoTree::Model::Tree->create($params);
    my $status = 200;
    if (exists $json->{error}) {
        my $error = $json->{error};
        if ($error == 1 || $error == 2) { # user does not exist or was deleted, forest does not exist
           $status = 406;
        } elsif ($error == 3) {
            $status = 403;
        }
    }
    $self->render(json => $json, status => $status); 
}

sub treeInfo {
    my $self = shift;
    
    my $params = {};
    $params->{treeid} = $self->param('treeid');
    $params->{userid} = $self->current_user->{userid};
    my $json = AnnoTree::Model::Tree->treeInfo($params);

    my $status = 200;
    if (exists $json->{error}) {
        my $error = $json->{error};
        if ($error == 1) { # tree does not exist
           $status = 406;
        }
    }
    
    $self->render(json => $json, status => $status); 
}

return 1;
