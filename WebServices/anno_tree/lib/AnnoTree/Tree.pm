package AnnoTree::Tree;

use Mojo::Base 'Mojolicious::Controller';

# placeholder data until I build the DB
my @trees = (
    [
        {
            id              => "0",
            name            => "AnnoTree",
            created         => "2013-05-20 23:34:43",
            icon            => "AnnoTree.png",
            description     => "A platform for design, bug testing, and collaboration for mobile applications"
        },
        {
            id              => "1",
            name            => "Radia",
            created         => "2012-07-23 14:13:12",
            icon            => "Radia.png",
            description     => "A tilt based iOS arcade game"
        }
    ],
    [
        {
            id              => "0",
            name            => "Rustled",
            created         => "2010-02-25 01:00:01",
            icon            => "Rustled.png",
            description     => "An application for those who have had their jimmies rustled"
        },
        {
            id              => "1",
            name            => "My",
            created         => "2010-03-03 16:16:16",
            icon            => "My.png",
            description     => "It's mine I say.  MINE!"
        },
        {
            id              => "2",
            name            => "Jimmies",
            created         => "2011-11-11 11:11:11",
            icon            => "Jimmies.png",
            description     => "Jimmy's personal project"
        }
    ],
    [
        {
            id              => "0",
            name            => "MattOS",
            created         => "2013-05-21 12:48:08",
            icon            => "MattRocks.png",
            description     => "An OS built completely in JS because JS is just so cool and does everything"
        },
        {
            id              => "1",
            name            => "HaHaHaHa",
            created         => "2007-06-29 00:00:01",
            icon            => "Lulz.png",
            description     => "The ladies\' default response to Brian"
        },
        {
            id              => "2",
            name            => "Marketing",
            created         => "2010-08-17 08:00:00",
            icon            => "Gross.png",
            description     => "What I want no part of.  I just build cool shit"
        },
        {
            id              => "3",
            name            => "Stock Market Up",
            created         => "2013-01-01 00:00:00",
            icon            => "DefiesLogic.png",
            description     => "Seriously how does the market only continue to go up?  I don't get it"
        }
    ]
);

# list all of the available trees for a forest
sub list {
    my $self = shift;
    my $forestid = $self->param('forestid');
    my $numTrees = scalar @{$trees[$forestid]};
    my $treeRef = $trees[$forestid];
    
    $self->render(name => 'list', format => 'json', treeRef => $treeRef);
}

return 1;
