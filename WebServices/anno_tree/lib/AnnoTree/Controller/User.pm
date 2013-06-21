package AnnoTree::Controller::User;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::User;
use Scalar::Util qw(looks_like_number);

sub testSignup {
    my $self = shift;
    
    #$self->db_test();
    #$self->debug($self->db_set);
    #$self->debug($self->testStr('blahblah'));

    $self->render(template => 'user/testsignup');
}

sub testLogin {
    my $self = shift;

    $self->render(template => 'user/testlogin');
}

sub login {
    my $self = shift;

    my $params = {};
    $params->{email} = $self->param('loginEmail');
    $params->{password} = $self->param('loginPassword');
    
    my $result = AnnoTree::Model::User::login($self, $params);
    if (exists $result->{result}) {
        my $error = $result->{result};
        #$self->debug("error is $error");
        if ($error == -1) { # user does not exist
            $self->render(json => $result, status => 404);
        } elsif ($error == 0) { # incorrect password
            $self->render(json => $result, status => 406);
        }
    } else {
        $self->render(json => $result);
    }
}

sub signup {
    my $self = shift;
    
    $self->debug($self->dumper($self->req->params));
    my $params = {};
    ($params->{'firstName'}, $params->{'lastName'}) = $self->param('signUpName') =~ m/(.+)\s+(\S+)\Z/;
    $params->{'email'} = $self->param('signUpEmail');
    $params->{'password'} = $self->param('signUpPassword');
    
    my $result = AnnoTree::Model::User->signup($params);
    
    if (looks_like_number($result)) {
        # something was wrong with one of the passed in parameters
        # 1: email sucks
        # 2: email already exists
        # 3: password is not at least 6 characters in length
        # 4: no number in password
        # 5: nonvalid character used
        $self->render(json => {result => '' . $result}, status => 406);
    } else {
        $self->render(json => $result);
    }
}

sub authenticateUser {
    
}

return 1;
