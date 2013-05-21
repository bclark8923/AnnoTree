package AnnoTree::Tree;

use Mojo::Base 'Mojolicious::Controller';

our @trees = (
    [
        {
            name            => "AnnoTree",
            datetime        => "2013-05-21 23:34:43",
            icon            => "AnnoTree.png",
            description     => "A platform for design, bug testing, and collaboration for mobile applications"
        },
        {
            name            => "Radia",
            datetime        => "2012-07-23 14:13:12",
            icon            => "Radia.png",
            description     => "A tilt based iOS arcade game"
        }
    ]
);

sub list {
    my $self = shift;
    my $forestid = $self->param('forestid');
    my $numTrees = scalar @trees[$forestid];
    #$self->render(text => "$forestid");
    my $msg = "\"numTrees\": \"$numTrees\"\n, \"trees\": [";
    #for (my $i = 0; $i < $trees[$forestid]; $i++) {
    #$msg .= "name: \"$trees[$forestid]->[$i]->{'name'}\"\n"
    #}
    $msg .= "\n]";
    $self->render(name => 'list', format => 'json', content => $msg);
}

return 1;
