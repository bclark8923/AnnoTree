package AnnoTree::Forest;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::ForestModel;

# placeholder data for forests until I build the DB
=begin placeholderData
my $forests = {
    numForests      => "3",
    forests         => [
        {
            id          => "0",
            name        => "Untitled Technologies",
            description => "A company for only the truly brave"
        },
        {
            id          => "1",
            name        => "The Monkey Knows",
            description => "How dare you try to rustle my jimmies"
        },
        {
            id          => "2",
            name        => "Late Night",
            description => "Because we will be pulling a bunch of these"
        }
    ]
};
=end placeholderData
=cut

sub list {
    my $self = shift;
    
    my $model = AnnoTree::ForestModel::getAllForests($self);

    #$self->debug($self->dumper($forests));
    $self->debug($self->dumper($model));

    $self->render(json => $model);
}

sub unique {
    my $self = shift;

    my $id = $self->param('id');

    $self->debug("before go id is $id");
    
    my $model = AnnoTree::ForestModel::getUniqueForest($self, $id);
    $self->render(json => $model);
}

return 1;
