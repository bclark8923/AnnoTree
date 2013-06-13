package AnnoTree::Controller::User;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::User;


sub testSignup {
    my $self = shift;

    $self->render(template => 'user/testsignup');
}

sub signup {
    my $self = shift;
    
    my $params = {};
    ($params->{'firstName'}, $params->{'lastName'}) = $self->param('signUpName') =~ m/(\S+)\s+(\S+)/;
    $params->{'email'} = $self->param('signUpEmail');
    $params->{'password'} = $self->param('signUpPassword');
    #$self->debug($self->dumper($params));
    
    my $result = AnnoTree::Model::User::signup($self, $params);
    
    $result == 1 ? $self->render(text => 'success') : $self->render(text => 'failed');
}

return 1;
