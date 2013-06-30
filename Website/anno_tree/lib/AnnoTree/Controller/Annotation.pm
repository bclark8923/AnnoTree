package AnnoTree::Controller::Annotation;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::Asset::File;
use AnnoTree::Model::Annotation;
use AppConfig;

# grab the inforamtion from the configuration file
my $config = AppConfig->new();
$config->define('server=s');
$config->define('port=s');
$config->define('screenshot=s');
$config->define('annotationpath=s');
$config->file('/opt/config.txt');
my $server = $config->get('server');
my $port = ':' . $config->get('port');
my $path = $config->get('annotationpath');
my $url = $server . $port . '/annotation_files/';

# creates a new annotation
sub create {
    my $self = shift;
    
    my $params = {};
    my $upload = $self->req->upload('uploadedFile');
    $self->render(json => {error => '0', txt => 'You must include a file'}, status => 406) and return unless defined $upload;
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
