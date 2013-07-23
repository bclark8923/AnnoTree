package AnnoTree::Controller::User;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::User;
use Scalar::Util qw(looks_like_number);

sub deleteUser {
    my $self = shift;

    my $userid = $self->param('userid');

    my $result = AnnoTree::Model::User->deleteUser($userid);
    
    my $status = 200;
    if (exists $result->{error}) {
        my $error = $result->{error};
        if ($error == 1) { # user does not exist
            $status = 404;
        }
    }

    $self->render(json => $result, status => $status);
}

sub knownPeople {
    my $self = shift;

    my $user = $self->current_user->{userid};

    my $json = AnnoTree::Model::User->knownPeople($user);

    $self->render(json => $json, status => 200);
}

# beta signup service
sub beta {
    my $self = shift;
    
    my $jsonReq = $self->req->json;
    my $email = $jsonReq->{email};

    my $json = AnnoTree::Model::User->beta($email);

    my $status = 204;
    if (exists $json->{error}) {
        $status = 406;
    }

    $self->render(json => $json, status => $status);
}

sub feedback {
    my $self = shift;

    my $jsonReq = $self->req->json;

    my $params = {};
    $params->{userid} = $self->current_user->{userid};
    $params->{feedback} = $jsonReq->{feedback};
    $self->debug($self->dumper($params));

    AnnoTree::Model::User->feedback($params);

    $self->render(status => 204, text => "Success");
}

# let's an user apply to reset their password
sub setReset {
    my $self = shift;

    my $jsonReq = $self->req->json;
    my $email = $jsonReq->{email};
    
    my $json = AnnoTree::Model::User->setReset($email);
    
    my $status = 204;
    $status = 406 if (exists $json->{error});

    $self->render(status => $status, json => $json)
}

# resets an user's password and authenticates them
sub reset {
    my $self = shift;

    my $jsonReq = $self->req->json;
    my $email = $jsonReq->{email};

}

return 1;
