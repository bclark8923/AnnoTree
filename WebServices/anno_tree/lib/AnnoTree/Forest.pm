package AnnoTree::Forest;

use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

# placeholder data for companies until I build the DB
my @companies = (
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

sub list {
    my $self = shift;
    
    my $companiesRef = \@companies;

    #$self->render(text => "Hello Forest");
    $self->render(name => 'list', format => 'json', companies => $companiesRef);
}

sub unique {
    my $self = shift;

    my $id = $self->param('id');

    $self->render(name => 'unique', format => 'json', company => $companies[$id]);
}

return 1;
