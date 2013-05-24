package AnnoTree::Leaves::Leaf;

use Mojo::Base 'Mojolicious::Controller';
#use 'Mojolicious::Plugins';
use Data::Dumper;

#plugin 'DebugHelper';

sub list {
    my $self = shift;

    $self->render(name => 'list', format => 'json');
}

sub testImageUpload {
    my $self = shift;

    $self->render(template => 'leaves/leaf/testupload', format => 'html');
}

sub imagePost {
    my $self = shift;

    #$self->app->log->debug(Dumper($self->ua));
    #my $image = $self->param('image');

    #$self->app->log->debug(Dumper($self->req->upload));
    
    my $upload = $self->req->upload('image');
    $self->app->log->debug(Dumper($upload));

    $upload->move_to("/opt/$upload->{filename}");

    $self->render(text => "Thanks for uploading $upload->{filename}");
#template => 'leaves/leaf/testupload', format => 'html');

}

return 1;
