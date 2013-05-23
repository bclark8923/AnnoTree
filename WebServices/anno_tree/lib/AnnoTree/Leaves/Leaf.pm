package AnnoTree::Leaves::Leaf;

use Mojo::Base 'Mojolicious::Controller';

sub list {
    my $self = shift;

    $self->render(name => 'list', format => 'json');
}

return 1;
