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
    $self->render(json => {error => '0', txt => 'Missing JSON name/value pairs in request'}, status => 406) and return unless (exists $jsonReq->{name} && exists $jsonReq->{description});

    my $params = {};
    $params->{userid} = $self->current_user->{userid};
    $params->{name} = $jsonReq->{'name'};
    $params->{desc} = $jsonReq->{'description'};

    $self->render(json => {error => '2', txt => 'No name for the forest provided - include at least one alphanumeric character'}, status => 406) and return unless ($params->{name} =~ m/[A-Za-z0-9]/);
    
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

sub update {
    my $self = shift;
    my $jsonReq = $self->req->json;

    $self->render(json => {error => '0', txt => 'Missing required JSON name/value pairs in request or they have no value'}, status => 406) and return unless ($jsonReq->{'description'} && $jsonReq->{name});
    $self->render(json => {error => '1', txt => 'Forest name must contain at least one alphanumeric character'}, status => 406) and return unless ($jsonReq->{name} =~ m/[A-Za-z0-9]/);

    my $params = {};
    $params->{forestid} = $self->param('forestid');
    $params->{desc} = $jsonReq->{'description'};
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
    
    my @annos = AnnoTree::Model::Forest->getForestAnnotations($params);
    my $json = AnnoTree::Model::Forest->deleteForest($params);
    
    my $status = 204;
    if (exists $json->{error}) {
        $status = 406;
    } else {
        foreach my $anno (@annos) {
            `rm $path/$anno`;
        }
    }

    $self->render(json => $json, status => $status);
}

return 1;
