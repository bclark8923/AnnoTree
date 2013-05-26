package AnnoTree::Leaves::Leaf;

use Mojo::Base 'Mojolicious::Controller';
#use 'Mojolicious::Plugins';
use Data::Dumper;

#plugin 'DebugHelper';

sub list {
    my $self = shift;
    
    push @{$self->app->plugins->namespaces}, 'AnnoTree::Plugin';
    
    #$self->debug('test');
    
    

    $self->render(name => 'list', format => 'json');
}

return 1;
