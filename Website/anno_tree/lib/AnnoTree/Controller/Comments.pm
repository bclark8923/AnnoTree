package AnnoTree::Controller::Comments;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::Comments;

sub leafCreate {
    my $self = shift;
    
    my $jsonReq = $self->req->json;

    $self->render(json => {error => '0', txt => 'No comment provided'}, status => 406) and return unless ($jsonReq->{comment} =~ m/.{1}/);

    my $params = {};
    $params->{userid} = $self->current_user->{userid};
    $params->{leafid} = $self->param('leafid');
    $params->{comment} = $jsonReq->{comment};
    
    my $json = AnnoTree::Model::Comments->leafCreate($params);

    my $status = 200;
    if (exists $json->{error}) {
       $status = 406;
    }

    $self->render(json => $json, status => $status);
}

sub leafInfo {
    my $self = shift;
    
    my $params = {};
    $params->{userid} = $self->current_user->{userid};
    $params->{leafid} = $self->param('leafid');

    my $json = AnnoTree::Model::Comments->leafInfo($params);

    my $status = 200;
    if (exists $json->{error}) {
       $status = 406;
    } elsif (!exists $json->{comments}) { # no comments for the leaf
        $status = 204;
    } 

    $self->render(json => $json, status => $status);
}

return 1;
