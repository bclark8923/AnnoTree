package AnnoTree::Controller::Static;

use Mojo::Base 'Mojolicious::Controller';

sub splash {
    my $self = shift;
    
    $self->redirect_to('/AnnoTreeWebsite/index.html');
}

sub login {
    my $self = shift;
    
    $self->redirect_to('/CCP/index.htm');
}
sub signup {
    my $self = shift;

    $self->redirect_to('/CCP/index.htm#/authenticate/signUp');
}

return 1;
