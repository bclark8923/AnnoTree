package Mojolicious::Plugin::DebugHelper;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
    my ($self, $app) = @_;
    
    $app->helper(debug => sub {
        my ($self, $str) = @_;
        $self->app->log->debug($str);
    });
}

return 1;
