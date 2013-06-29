package AnnoTree::Controller::Annotation;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::Asset::File;
use AnnoTree::Model::Annotation;

my $mattPath = '/home/matt/reserve/AnnoTree/';
my $awsPath = '/opt/www/';
my $path = $mattPath . 'Website/anno_tree/public/annotation_files/';
my $url = 'http://23.21.235.254:3000/annotation_files/';

# creates a new annotation
sub create {
    my $self = shift;
    
    $self->debug($self->dumper($self->req));
    my $params = {};
    my $upload = $self->req->upload('uploadedFile');
    $self->render(json => {error => '0', txt => 'You must include a file'}, status => 406) and return unless defined $upload;
    $self->debug($self->dumper($upload->headers->content_type));
    $params->{leafid} = $self->param('leafid');
    my $fsName = $params->{leafid} . '_' . $upload->{filename};
    $params->{filename} = $upload->{filename};
    $params->{path} = $url . $fsName;
    $params->{mime} = $upload->headers->content_type;
    $upload->move_to($path . $fsName);
    
    my $json = AnnoTree::Model::Annotation->create($params);
    my $status = 200;
    if (exists $json->{error}) {
        my $error = $json->{error};
        if ($error == 1) { # leaf does not exist
           $status = 406;
        }
        `rm $path/$fsName`;
    }

    $self->render(status => $status, json => $json);
}

sub testFileUpload {
    my $self = shift;
    
    $self->render(template => 'leaves/annotation/testupload');
}

return 1;
