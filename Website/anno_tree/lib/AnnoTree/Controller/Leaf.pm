package AnnoTree::Controller::Leaf;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::Leaf;
use AppConfig;

# grab the inforamtion from the configuration file
my $config = AppConfig->new();
$config->define('server=s');
$config->define('port=s');
$config->define('screenshot=s');
$config->define('annotationpath=s');
$config->define('devRoot=s');
$config->file('/opt/config.txt');
my $server = $config->get('server');
my $port = ':' . $config->get('port');
my $path = $config->get('annotationpath');
my $url = $server . $port . '/annotation_files/';

# creates a new leaf
sub create {
    my $self = shift;
    
    my $jsonReq = $self->req->json;
    $self->render(json => {error => '0', txt => 'Missing JSON name/value pairs in request'}, status => 406) and return unless (exists $jsonReq->{name} && exists $jsonReq->{description}); 
    
    my $params = {};
    $params->{branchid} = $self->param('branchid');
    $params->{userid} = $self->current_user->{userid};
    $params->{name} = $jsonReq->{name};
    $params->{desc} = $jsonReq->{description};
    $self->render(json => {error => '4', txt => 'No name for the leaf provided - include at least one alphanumeric character'}, status => 406) and return unless ($params->{name} =~ m/[A-Za-z0-9]/);

    my $json = AnnoTree::Model::Leaf->create($params);
    my $status = 200;
    if (exists $json->{error}) {
        my $error = $json->{error};
        if ($error == 1 || $error == 2) { # user does not exist or was deleted, branch does not exist
           $status = 406;
        }
    }
    $self->render(json => $json, status => $status); 
}

sub update {
    my $self = shift;

    my $jsonReq = $self->req->json;
    $self->debug($self->dumper($jsonReq));
    $self->render(json => {error => '0', txt => 'Missing required JSON name/value pairs in request or they have no value'}, status => 406) and return unless ($jsonReq->{'description'} && $jsonReq->{'name'} && exists $jsonReq->{'branchid'});
    $self->render(json => {error => '5', txt => 'Leaf name must contain at least one alphanumeric character'}, status => 406) and return unless ($jsonReq->{'name'} =~ m/[A-Za-z0-9]/);

    my $params = {};
    $params->{leafid} = $self->param('leafid');
    $params->{desc} = $jsonReq->{description};
    $params->{name} = $jsonReq->{name};
    $params->{reqUser} = $self->current_user->{userid};
    $params->{branchid} = $jsonReq->{branchid};
    $self->debug($self->dumper($params));
    my $json = AnnoTree::Model::Leaf->update($params);
    my $status = 204;
    if (exists $json->{error}) {
       $status = 406;
    }
    $self->render(json => $json, status => $status);
}

sub leafInfo {
    my $self = shift;

    my $params = {};
    $params->{userid} = $self->current_user->{userid};
    $params->{leafid} = $self->param('leafid');
    
    my $json = AnnoTree::Model::Leaf->leafInfo($params);
    
    my $status = 200;
    if (exists $json->{error}) {
        my $error = $json->{error};
        if ($error == 1) { # leaf does not exist
           $status = 406;
        }
    }
    
    $self->render(json => $json, status => $status);
}

sub iosUpload {
    my $self = shift;
    #$self->debug($self->dumper($self->req));
    my $params = {};
    $params->{token} = $self->param('token');
    $params->{leafName} = $self->param('leafName');
    my $upload = $self->req->upload('annotation');
    $self->render(json => {error => '0', txt => 'Missing form request parameters or they are ill formed'}, status => 406) and return unless ($params->{token} && $params->{token} =~ m/[a-f0-9]{64}/ && defined $upload && exists $upload->{filename} && $upload->{filename} ne '' && $self->param('leafName') && $self->param('leafName') =~ m/[a-zA-Z0-9]/);
    #$self->debug($self->dumper($upload));
    #$self->debug("token: $params->{token} \n filename: $upload->{filename} \n content-type: " . $upload->headers->content_type . "\n");
    $params->{filename} = $upload->{filename};
    $params->{mime} = $upload->headers->content_type;
    $params->{path} = $url;
    #$params->{fileLoc} = $path;
    # get branch id (based on tree token)
    # create new leaf on branch (get leafid)
    # add annotation to leaf
    my $json = AnnoTree::Model::Leaf->iosUpload($params);
    my $status = 200;
    if (exists $json->{error}) {
        $status = 406;
    } else {
        $upload->move_to($path . $json->{fsName});
        $json = {result => 'Leaf and annotation successfully created'};
    }

    $self->render(json => $json, status => $status);
}

sub iosTestUpload {
    my $self = shift;

    $self->render(template => 'leaves/testupload');
}

sub deleteLeaf {
    my $self = shift;
    
    my $params = {};
    $params->{reqUser} = $self->current_user->{userid};
    $params->{leafid} = $self->param('leafid');
    my $json = AnnoTree::Model::Leaf->deleteLeaf($params);

    my $status = 204;
    if (exists $json->{error}) {
        $status = 406;
    } else {
        `rm $path/$json->{txt}` if ($json->{txt});
    }

    $self->render(json => $json, status => $status);
}

return 1;
