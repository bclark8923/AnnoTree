package AnnoTree::Controller::Forest;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::Forest;
use Scalar::Util qw(looks_like_number);

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
    
    my $status = 200;
    if (exists $result->{error}) {
        my $error = $result->{error};
        if ($error == 0) {
            $status = 204;
        } elsif ($error = 1) {
            $status = 404;
        }
    }
    
    $self->render(json => $result, status => $status);

}

return 1;
