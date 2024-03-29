package AnnoTree::Controller::Forest;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::Forest;
use Config::General;

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;
my $path = $config{server}->{'annotationpath'};

sub create {
    my $self = shift;
    
    my $jsonReq = $self->req->json;
    $self->render(json => {error => '0', txt => 'Please enter a forest name'}, status => 406) and return unless (exists $jsonReq->{name});

    my $params = {};
    $params->{userid} = $self->current_user->{userid};
    $params->{name} = $jsonReq->{'name'};

    $self->render(json => {error => '2', txt => 'A forest name must include at least one alphanumeric character'}, status => 406) and return unless ($params->{name} =~ m/[A-Za-z0-9]/);
    
    my $json = AnnoTree::Model::Forest->create($params);
    
    my $status = 200;
    if (exists $json->{error}) {
        my $error = $json->{error};
        if ($error == 1) { # user does not exist or was deleted
           $status = 406;
       }
    }
    $self->render(json => $json, status => $status);
}

sub forestInfo {
    my $self = shift;

    my $userid = $self->current_user->{userid};

    my $json = AnnoTree::Model::Forest->forestInfo($userid);
    
    my $status = 200;
    if (exists $json->{error}) {
        my $error = $json->{error};
        if ($error == 2) { # no forests for user
            $status = 204;
        } elsif ($error = 1) { # user does not exist or was deleted
            $status = 406;
        }
    }
    
    $self->render(json => $json, status => $status);

}

#TODO: errors for if db connection fails
sub update {
    my $self = shift;
    my $jsonReq = $self->req->json;

    $self->render(json => {error => '0', txt => 'Missing required JSON name/value pairs in request or they have no value'}, status => 406) and return unless ($jsonReq->{name});
    $self->render(json => {error => '1', txt => 'Forest name must contain at least one alphanumeric character'}, status => 406) and return unless ($jsonReq->{name} =~ m/[A-Za-z0-9]/);

    my $params = {};
    $params->{forestid} = $self->param('forestid');
    $params->{reqUser} = $self->current_user->{userid};
    $params->{name} = $jsonReq->{name};
    $self->debug($self->dumper($params));
    my $json = AnnoTree::Model::Forest->update($params);
    my $status = 204;
    if (exists $json->{error}) {
       $status = 406;
    }
    $self->render(json => $json, status => $status);
}

sub deleteForest {
    my $self = shift;

    my $params = {};
    $params->{reqUser} = $self->current_user->{userid};
    $params->{forestid} = $self->param('forestid');
    
    #my @annos = AnnoTree::Model::Forest->getForestAnnotations($params);
    my $json = AnnoTree::Model::Forest->deleteForest($params);
    
    my $status = 204;
    if (exists $json->{error}) {
        $status = 406;
    } else {
        `rm -rf $path/$params->{forestid}`; # TODO: use perl library, place in model
    }

    $self->render(json => $json, status => $status);
}

sub forestUsers {
    my $self = shift;

    my $params = {};
    $params->{userid} = $self->current_user->{userid};
    $params->{forestid} = $self->param('forestid');
    
    my $json = AnnoTree::Model::Forest->forestUsers($params);

    my $status = 200;
    if (exists $json->{error}) {
        $status = 406;
    }

    $self->render(json => $json, status => $status);
}

sub updateOwner {
    my $self = shift;
    
    my $jsonReq = $self->req->json;

    $self->render(json => {error => '0', txt => 'Please select a new owner'}, status => 406) and return unless ($jsonReq->{owner});

    my $params = {};
    $params->{reqUser} = $self->current_user->{userid};
    $params->{forestid} = $self->param('forestid');
    $params->{newOwner} = $jsonReq->{owner};

    my $json = AnnoTree::Model::Forest->updateOwner($params);

    my $status = 200;
    if (exists $json->{error}) {
        $status = 406;
    }

    $self->render(json => $json, status => $status);
}

return 1;
