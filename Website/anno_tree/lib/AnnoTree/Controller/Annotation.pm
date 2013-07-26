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

    $params->{filename} = $upload->{filename};
    $params->{path} = $server . '/services/annotation/';
    $params->{mime} = $upload->headers->content_type;

    
    my $json = AnnoTree::Model::Annotation->create($params);
    my $status = 200;
    if (exists $json->{error}) {
        my $error = $json->{error};
        if ($error == 1) { # leaf does not exist
           $status = 406;
        }

    } else {
        my ($diskDir) = $json->{filename_disk} =~ m{(.*)/};
        my @dir = split(/\//, $diskDir);
        `mkdir $path/$dir[0]` unless (-d "$path/$dir[0]");
        `mkdir $path/$dir[0]/$dir[1]` unless (-d "$path/$dir[0]/$dir[1]");
        `mkdir $path/$dir[0]/$dir[1]/$dir[2]` unless (-d "$path/$dir[0]/$dir[1]/$dir[2]");
        $upload->move_to($path . $json->{filename_disk});
        delete $json->{filename_disk};
    }
    $self->render(status => $status, json => $json);
}

sub getImage {
    my $self = shift;
    
    # check that the user has access to that annotation
    my $params = {};
    $params->{userid} = $self->current_user->{userid};
    $params->{annoid} = $self->param('annoid');
    my $result = AnnoTree::Model::Annotation->getImage($params);
    
    $result->[0] ? 
        $self->render_static('annotation_files/' . $result->[1]) :
        $self->render(status => '403', json => {txt => 'You are not authorized to view this annotation.', error => '0'});
}

return 1;
