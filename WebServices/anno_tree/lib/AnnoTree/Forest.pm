package AnnoTree::Forest;

use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

# placeholder data for forests until I build the DB
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
=begin comment
#this structure was used with json ep templates - leveraging json stash value instead which
#converts json stash values directly to encoded json
my @forests = (
    {
        numForests  => "3"
    },
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
);
=end comment
=cut 
sub list {
    my $self = shift;
    
    #my $forestsRef = \@forests;

    $self->render(json => $forests);
    #$self->render(name => 'list', format => 'json', forests => $forestsRef);
}

sub unique {
    my $self = shift;

    my $id = $self->param('id');
    
    $self->render(json => $forests->{forests}->[$id]);
    #$self->render(name => 'unique', format => 'json', forest => $forests->{forests}->[$id]);
}

return 1;
