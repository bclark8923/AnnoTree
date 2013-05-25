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

sub testImageUpload {
    my $self = shift;
    
    #my $debug = $self->plugin('DebugHelper');
    
    $self->render(template => 'leaves/leaf/testupload', format => 'html');
}

sub imagePost {
    my $self = shift;

    #$self->app->log->debug(Dumper($self->ua));
    #my $image = $self->param('image');

    #$self->app->log->debug(Dumper($self->req->upload));
    $self->app->log->debug(Dumper($self->req));
    
    my $upload = $self->req->upload('image');
    $self->app->log->debug(Dumper($upload));

    $upload->move_to("/opt/$upload->{filename}");

    $self->render(text => "Thanks for uploading $upload->{filename}");
#template => 'leaves/leaf/testupload', format => 'html');

}

return 1;
