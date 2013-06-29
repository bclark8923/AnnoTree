package AnnoTree::Controller::Annotation;

use Mojo::Base 'Mojolicious::Controller';
#use AnnoTree::Model::Leaf;

# creates a new leaf
sub create {
    my $self = shift;
    
    $self->debug($self->dumper($self->req));
    
    $self->render(txt => 'fuck the p0lice');
}

sub testFileUpload {
    my $self = shift;
    
    $self->render(template => 'leaves/annotation/testupload');
}

return 1;
