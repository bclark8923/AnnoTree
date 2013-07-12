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

return 1;
