package AnnoTree::Controller::Annotation;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::Asset::File;
use AnnoTree::Model::Annotation;
use Config::General;

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;
my $server = $config{server}->{'base_url'};
my $port = ':' . $config{server}->{'port'};
my $path = $config{server}->{'annotationpath'};
my $url = $server . $port . '/annotation_files/';

# creates a new annotation
sub create {
    my $self = shift;
    
    my $params = {};
    my $upload = $self->req->upload('uploadedFile');
    $self->render(json => {error => '0', txt => 'You must include a file'}, status => 406) and return unless (defined $upload && exists $upload->{filename} && $upload->{filename} ne '');
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
