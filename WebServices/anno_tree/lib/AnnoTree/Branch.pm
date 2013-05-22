package AnnoTree::Branch;

use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;


# placeholder data until I build the DB
my @branches = (
    [ # Untitled forest
        [ # AnnoTree tree
            { #a branch
                id          => "0",
                name        => "App",
                description => "The mobile application",
                created     => "2013-05-21 00:10:34",
                status      => "active"
            },
            {
                id          => "1",
                name        => "CCP",
                description => "The web based collaboration platform",
                created     => "2013-05-21 11:46:54",
                status      => "active" 
            }
        ],
        [ # Radia tree
            { #a branch
                id          => "0",
                name        => "Tilt",
                description => "Tilting function",
                created     => "2012-08-26 18:56:02",
                status      => "closed"
            },
            {
                id          => "1",
                name        => "Graphics",
                description => "The images and how the game displays",
                created     => "2012-08-01 20:21:52",
                status      => "closed" 
            },
            {
                id          => "2",
                name        => "Game Logic",
                description => "How the game actually plays",
                created     => "2012-10-10 09:34:43",
                status      => "closed" 
            }
        ]
    ],
    [ # the monkey knows forest
        [ # rustled tree
            { #a branch
                id          => "0",
                name        => "Run",
                description => "You should run if you\'re rustled",
                created     => "2010-04-13 18:56:02",
                status      => "inactive"
            },
            {
                id          => "1",
                name        => "Stop",
                description => "Stop, drop, and roll br0s - that\'s a best practice",
                created     => "2011-08-01 20:21:52",
                status      => "active" 
            } 
        ],
        [ # my tree
        ],
        [ # jimmies tree
           { #a branch
                id          => "0",
                name        => "Picture",
                description => "Pictures of Jimmy Rustling",
                created     => "2010-04-13 18:56:02",
                status      => "active"
            },
            {
                id          => "1",
                name        => "Something",
                description => "This is a description of something",
                created     => "2011-08-01 20:21:52",
                status      => "closed" 
            } 
        ]
    ],
    [ # late night forest
        [ # MattOS tree
           { #a branch
                id          => "0",
                name        => "Kernel",
                description => "The central piece of any OS",
                created     => "2013-05-22 18:56:02",
                status      => "active"
            },
            {
                id          => "1",
                name        => "GUI",
                description => "The graphical user interface - of course its built in JS",
                created     => "2013-05-23 20:21:52",
                status      => "active" 
            },
            {
                id          => "2",
                name        => "Applications",
                description => "Stuff like OpenOffice, a calculator, and Firefox but all JavaScriptized",
                created     => "2013-05-24 20:21:52",
                status      => "active" 
            } 
        ],
        [ # HaHaHaHa tree
           { #a branch
                id          => "0",
                name        => "No",
                description => "All the no answers that Brian gets",
                created     => "2007-07-01 00:00:00",
                status      => "active"
            },
            {
                id          => "1",
                name        => "Are You Serious",
                description => "All the answers that are like this that Brian gets",
                created     => "2009-03-09 20:21:52",
                status      => "inactive" 
            } 
        ],
        [ # marketing tree
           { #a branch
                id          => "0",
                name        => "Boring",
                description => "Marketing is really boring and so is this description dude",
                created     => "2010-08-18 00:00:00",
                status      => "active"
            },
            {
                id          => "1",
                name        => "Fun",
                description => "Can marketing even be fun? We go to the streets to find out",
                created     => "2011-06-09 20:21:52",
                status      => "inactive" 
            } 
        ],
        [ # stock market up
        ]
    ]
);

sub list {
    my $self = shift;

    my $forestid = $self->param('forestid');
    my $treeid = $self->param('treeid');
    my $branchRef = $branches[$forestid][$treeid];
    #$self->app->log->debug(Dumper($branchRef));

    $self->render(name => 'list', format => 'json', branchRef => $branchRef);
}

return 1;
