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

    $self->render(json => $result);
}

sub signup {
    my $self = shift;
    
    my $params = {};
    ($params->{'firstName'}, $params->{'lastName'}) = $self->param('signUpName') =~ m/(.+)\s+(\S+)\Z/;
    $params->{'email'} = $self->param('signUpEmail');
    $params->{'password'} = $self->param('signUpPassword');
    
    my $result = AnnoTree::Model::User->signup($params);
    
    if (looks_like_number($result)) {
        # something was wrong with one of the passed in parameters
        # 1: email sucks
        # 2: email already exists
        $self->render(json => {result => '' . $result}, status => 406);
    } else {
        $self->render(json => $result);
    }
}

sub authenticateUser {
    
}

return 1;
