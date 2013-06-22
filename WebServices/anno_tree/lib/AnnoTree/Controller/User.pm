package AnnoTree::Controller::User;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::User;
use Scalar::Util qw(looks_like_number);

# handles user login
sub login {
    my $self = shift;

    my $jsonReq = $self->req->json;
    $self->debug($self->dumper($jsonReq));
    
    $self->render(json => {error => '6'}, status => 406) and return unless (exists $jsonReq->{loginEmail} && exists $jsonReq->{loginPassword});
    
    my $params = {};
    $params->{email} = $jsonReq->{'loginEmail'};
    $params->{password} = $jsonReq->{'loginPassword'};
    
    my $result = AnnoTree::Model::User::login($self, $params);
    if (exists $result->{error}) {
        my $error = $result->{error};
        if ($error == 1) { # user does not exist
            $self->render(json => $result, status => 404);
        } elsif ($error == 0) { # incorrect password
            $self->render(json => $result, status => 406);
        }
    } else {
        $self->render(json => $result);
    }
}

# handles user signup
# Need to add:
# 1) Create a forest, tree, branch, sample leaves if not an user referred to the forest
# 2) If a referred user need to add to forest and/or trees
sub signup {
    my $self = shift;
    
    my $jsonReq = $self->req->json;
    $self->debug($self->dumper($jsonReq));
    
    $self->render(json => {error => '6'}, status => 406) and return unless (exists $jsonReq->{signUpName} && exists $jsonReq->{signUpEmail} && exists $jsonReq->{signUpPassword});

    my $params = {};
    ($params->{'firstName'}, $params->{'lastName'}) = $jsonReq->{'signUpName'} =~ m/(.+)\s+(\S+)\Z/;
    $params->{'email'} = $jsonReq->{'signUpEmail'};
    $params->{'password'} = $jsonReq->{'signUpPassword'};
    
    my $result = AnnoTree::Model::User->signup($params);
    $self->debug($self->dumper($result));
    if (looks_like_number($result)) {
        # something was wrong with one of the passed in parameters
        # 1: email sucks
        # 2: email already exists
        # 3: password is not at least 6 characters in length
        # 4: no number in password
        # 5: nonvalid character used
        $self->render(json => {error => '' . $result}, status => 406);
    } else {
        $self->render(json => $result);
    }
}

sub deleteUser {
    my $self = shift;

    my $userid = $self->param('uid');

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

return 1;
