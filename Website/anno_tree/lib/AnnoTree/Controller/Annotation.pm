package AnnoTree::Controller::Annotation;

use Mojo::Base 'Mojolicious::Controller';
#use AnnoTree::Model::Leaf;

my $mattPath = '/home/matt/reserve/AnnoTree/';
my $awsPath = '/opt/www/';
my $path = $mattPath . 'Website/anno_tree/public/annotation_files/';

# creates a new annotation
sub create {
    my $self = shift;
    
    $self->debug($self->dumper($self->req));
    my $upload = $self->req->upload('uploadedFile');
    $upload->move_to($path . $upload->{filename});
    
    $self->render(status => 200, json => {something => 'something'});
}

sub testFileUpload {
    my $self = shift;
    
    $self->render(template => 'leaves/annotation/testupload');
}

return 1;
