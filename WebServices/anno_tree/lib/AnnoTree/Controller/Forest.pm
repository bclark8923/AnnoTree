package AnnoTree::Controller::Forest;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::Forest;
use Scalar::Util qw(looks_like_number);

sub uniqueForest {
    my $self = shift;

    my $id = $self->param('id');

    $self->debug("before go id is $id");
    
    my $model = AnnoTree::Model::Forest->uniqueForest($id);
    $self->render(json => $model);
}

sub create {
    my $self = shift;
    
    my $jsonReq = $self->req->json;
    $self->debug($self->dumper($jsonReq));
    $self->render(json => {error => '6'}, status => 406) and return unless (exists $jsonReq->{name} && exists $jsonReq->{description});

    my $params = {};
    $params->{userid} = $self->param('userid');
    $params->{name} = $jsonReq->{'name'};
    $params->{desc} = $jsonReq->{'description'};
    
    my $result = AnnoTree::Model::Forest->create($params);
    
    my $status = 200;
    if (exists $result->{error}) {
        my $error = $result->{error};
        if ($error == 1) { # user does not exist or was deleted
           $status = 404;
       }
    }
    $self->render(json => $result, status => $status);
}

sub forestsForUser {
    my $self = shift;

    my $params = {};
    $params->{userid} = $self->param('userid');

    my $result = AnnoTree::Model::Forest->forestsForUser($params);
    
    if (looks_like_number($result)) {
        $self->render(status => 204, json => {txt => 'No forests were found for this user'});
    } else {
        $self->render(json => $result);
    }
}

return 1;
