package AnnoTree::Forest;

use Mojo::Base 'Mojolicious::Controller';

sub list {
    my $self = shift;

    #$self->render(text => "Hello Forest");
    $self->render(name => 'list', format => 'json');
}

sub unique {
    my $self = shift;

    my @companies = (
        {
            name        => "Untitled Technologies",
            description => "A company for only the truly brave"
        },
        {
            name        => "The Monkey Knows",
            description => "How dare you try to rustle my jimmies"
        },
        {
            name        => "Late Night",
            description => "Because we will be pulling a bunch of these"
        }
    );

    my $id = $self->param('id');

    $self->render(name => 'unique', format => 'json', companyName => "$companies[$id]->{'name'}", desc => "$companies[$id]->{'description'}");
}

return 1;
