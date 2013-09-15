package AnnoTree::Controller::Leaf;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::Leaf;
use Config::General;

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;
my $server = $config{server}->{'base_url'};
my $port = ':' . $config{server}->{'port'};
my $path = $config{server}->{'annotationpath'};
my $url = $server . $port . '/annotation_files/';

#TODO: fix how error returns are handled
# creates a new leaf
sub create {
    my $self = shift;
    
    my $jsonReq = $self->req->json;
    $self->render(json => {error => '0', txt => 'Please enter a leaf name'}, status => 406) and return unless (exists $jsonReq->{name}); 
    
    my $params = {};
    $params->{branchid} = $self->param('branchid');
    $params->{userid} = $self->current_user->{userid};
    $params->{name} = $jsonReq->{name};
    $self->render(json => {error => '4', txt => 'A leaf name must include at least one alphanumeric character'}, status => 406) and return unless ($params->{name} =~ m/[A-Za-z0-9]/);

    my $json = AnnoTree::Model::Leaf->create($params);
    my $status = 200;
    $status = 406 if (exists $json->{error});
    
    $self->render(json => $json, status => $status); 
}

sub rename {
    my $self = shift;

    my $jsonReq = $self->req->json;
    $self->render(json => {error => '0', txt => 'Please enter a leaf name'}, status => 406) and return unless ($jsonReq->{'name'});
    $self->render(json => {error => '2', txt => 'A leaf name must contain at least one alphanumeric character'}, status => 406) and return unless ($jsonReq->{'name'} =~ m/[A-Za-z0-9]/);

    my $params = {};
    $params->{leafid} = $self->param('leafid');
    $params->{name} = $jsonReq->{name};
    $params->{reqUser} = $self->current_user->{userid};
    
    my $json = AnnoTree::Model::Leaf->rename($params);
    my $status = 204;
    $status = 406 if (exists $json->{error});
    
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

# logging post parameters in development
sub iosUpload {
    my $self = shift;
    
    my $params = {};
    $params->{token} = $self->param('token');
    $params->{leafName} = $self->param('leafName');
    my $upload = $self->req->upload('annotation');
    $self->render(json => {error => '0', txt => 'Missing form request parameters or they are ill formed'}, status => 406) and return 
        unless ($params->{token} && $params->{token} =~ m/[a-f0-9]{64}/ && defined $upload 
        && exists $upload->{filename} && $upload->{filename} ne '' && $self->param('leafName') 
        && $self->param('leafName') =~ m/[a-zA-Z0-9]/);
    
    $params->{filename} = $upload->{filename};
    $params->{mime} = $upload->headers->content_type;

    # limit annotations to only images
    $self->render(json => {error => '0', txt => 'You can only upload images'}, status => 415) and return unless $params->{mime} =~ m/image/;

    $params->{path} = $server . '/services/annotation/';
    $params->{metaSystem} = $self->param('metaSystem') || undef;
    $params->{metaVersion} = $self->param('metaVersion') || undef;
    $params->{metaModel} = $self->param('metaModel') || undef;
    $params->{metaVendor} = $self->param('metaVendor') || undef;
    $params->{metaOrientation} = $self->param('metaOrientation') || undef;
    #TODO: upload plugin
    my $json = AnnoTree::Model::Leaf->iosUpload($params, $path);
    my $status = 200;
    if (exists $json->{error}) {
        $status = 406;
    } else {
        $upload->move_to($path . $json->{filename_disk});
        delete $json->{filename_disk};
    }

    $self->render(json => $json, status => $status);
}

#TODO: delete
sub iosTestUpload {
    my $self = shift;

    $self->render(template => 'leaves/testupload');
}

sub chromeUpload {
    my $self = shift;
    my $jsonReq = $self->req->json;
    
    my $params = {};
    $params->{token} = $jsonReq->{token};
    $params->{leafName} = $jsonReq->{leafName};
    $params->{annotation} = $jsonReq->{annotation};
    $self->render(json => {error => '0', txt => 'Missing request parameters or they are ill formed'}, status => 406) and return unless ($params->{token} && $params->{token} =~ m/[a-f0-9]{64}/ && $params->{annotation} =~ m/image\/jpeg/ && $params->{leafName} && $params->{leafName} =~ m/[a-zA-Z0-9]/);
    $params->{annotation} =~ s/data:image\/jpeg;base64,//; 
    $params->{owner} = $jsonReq->{owner};
    $params->{metaSystem} = $jsonReq->{metaSystem};
    $params->{metaVendor} = $jsonReq->{metaVendor};
    $params->{site} = $jsonReq->{site};
    $params->{mime} = 'image/jpeg';
    $params->{filename} = 'chrome_screenshot.jpg';
    ($params->{metaVersion}) = $jsonReq->{metaVersion} =~ m/Chrome\/([\.0-9a-zA-Z]+)/;
    $params->{path} = $server . '/services/annotation/';
    $params->{metaModel} = $jsonReq->{metaModel};
    $params->{metaOrientation} = 'landscape';
    
    my $json = AnnoTree::Model::Leaf->chromeUpload($params, $path);
    my $status = 200;
    if (exists $json->{error}) {
        $status = 406;
    }

    $self->render(json => $json, status => $status);
}

sub deleteLeaf {
    my $self = shift;
    
    my $params = {};
    $params->{reqUser} = $self->current_user->{userid};
    $params->{leafid} = $self->param('leafid');
    my $json = AnnoTree::Model::Leaf->deleteLeaf($params);

    my $status = 204; #TODO: teteriary ?: operator instead
    if (exists $json->{error}) {
        $status = 406;
    }

    $self->render(json => $json, status => $status);
}

sub changeBranch {
    my $self = shift;

    my $params = {};
    $params->{user} = $self->current_user->{userid};
    $params->{leafid} = $self->param('leafid');
    $params->{branchid} = $self->param('branchid');
    $params->{treeid} = $self->param('treeid');
    my $json = AnnoTree::Model::Leaf->changeBranch($params);

    my $status = 204;
    $status = 406 if (exists $json->{error});

    $self->render(json => $json, status => $status);
}

sub changeSubBranch {
    my $self = shift;

    my $jsonReq = $self->req->json;
    my $params = {};
    $params->{user} = $self->current_user->{userid};
    $params->{leafid} = $self->param('leafid');
    $params->{newBranchid} = $self->param('branchid');
    $params->{treeid} = $self->param('treeid');
    $params->{oldBranchid} = $jsonReq->{oldBranch};
    $params->{newPriority} = $jsonReq->{newPriority};
    $params->{oldPriority} = $jsonReq->{oldPriority};
    $self->debug($self->dumper($params));
    my $json = AnnoTree::Model::Leaf->changeSubBranch($params);

    my $status = 204;
    $status = 406 if (exists $json->{error});

    $self->render(json => $json, status => $status);
}

return 1;
