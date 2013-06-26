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

sub testAuth {
    my $self = shift;
    
    $self->render(txt => 'You are authenticated');
}

return 1;
