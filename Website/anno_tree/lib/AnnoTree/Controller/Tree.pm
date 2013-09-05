package AnnoTree::Controller::Tree;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::Tree;
use Config::General;
use Email::Valid;

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;
my $path = $config{server}->{'annotationpath'};

# creates a new tree
sub create {
    my $self = shift;
    
    my $jsonReq = $self->req->json;
    $self->render(json => {error => '0', txt => 'Please enter a tree name'}, status => 406) and return unless (exists $jsonReq->{name}); 
    my $params = {};
    $params->{forestid} = $self->param('forestid');
    $params->{userid} = $self->current_user->{userid};
    $params->{name} = $jsonReq->{name};
    $params->{logo} = 'img/logo.png';
    $self->render(json => {error => '4', txt => 'A tree name must include at least one alphanumeric character'}, status => 406) and return unless ($params->{name} =~ m/[A-Za-z0-9]/);

    my $json = AnnoTree::Model::Tree->create($params);
    my $status = 200;
    if (exists $json->{error}) {
        my $error = $json->{error};
        if ($error == 1 || $error == 2) { # user does not exist or was deleted, forest does not exist
           $status = 406;
        } elsif ($error == 3) {
            $status = 403;
        }
    }
    $self->render(json => $json, status => $status); 
}

sub treeInfo {
    my $self = shift;
    
    my $params = {};
    $params->{treeid} = $self->param('treeid');
    $params->{userid} = $self->current_user->{userid};
    my $json = AnnoTree::Model::Tree->treeInfo($params);

    my $status = 200;
    if (exists $json->{error}) {
        my $error = $json->{error};
        if ($error == 1) { # tree does not exist
           $status = 406;
        }
    }
    
    $self->render(json => $json, status => $status); 
}

sub update {
    my $self = shift;
    my $jsonReq = $self->req->json;

    $self->render(json => {error => '0', txt => 'Missing required JSON name/value pairs in request or they have no value'}, status => 406) and return unless ($jsonReq->{'description'} && $jsonReq->{'name'});
    $self->render(json => {error => '1', txt => 'Tree name must contain at least one alphanumeric character'}, status => 406) and return unless ($jsonReq->{'name'} =~ m/[A-Za-z0-9]/);

    my $params = {};
    $params->{treeid} = $self->param('treeid');
    $params->{name} = $jsonReq->{'name'};
    $params->{desc} = $jsonReq->{'description'};
    $params->{reqUser} = $self->current_user->{userid};

    my $json = AnnoTree::Model::Tree->update($params);
    my $status = 204;
    if (exists $json->{error}) {
       $status = 406;
    }
    $self->render(json => $json, status => $status);
}

sub addUserToTree {
    my $self = shift;
    
    my $jsonReq = $self->req->json;
    $self->render(json => {error => '3', txt => 'Missing JSON name/value pairs in request'}, status => 406) and return unless (exists $jsonReq->{userToAdd});
    
    $self->render(json => {error => '2', txt => 'Please enter a valid email'}, status => 406) and return unless (Email::Valid->address($jsonReq->{userToAdd}));

    my $params = {};
    $params->{treeid} = $self->param('treeid');
    $params->{requestingUser} = $self->current_user->{userid};
    $params->{userToAdd} = $jsonReq->{userToAdd};
    my $json = AnnoTree::Model::Tree->addUserToTree($params);
    
    my $status = 200;
    if (exists $json->{error}) {
       $status = 406;
    }
    
    $self->render(json => $json, status => $status);
}

sub deleteTree {
    my $self = shift;

    my $params = {};
    $params->{reqUser} = $self->current_user->{userid};
    $params->{treeid} = $self->param('treeid');
    
    #TODO check my @annos = AnnoTree::Model::Tree->getTreeAnnotations($params);
    my $json = AnnoTree::Model::Tree->deleteTree($params);
    
    my $status = 204;
    if (exists $json->{error}) {
        $status = 406;
    } else {
        `rm -rf $path/$json->{forestid}/$params->{treeid}`;
        delete $json->{forestid};
    }

    $self->render(json => $json, status => $status);
}

sub removeUserFromTree {
    my $self = shift;

    my $params = {};
    $params->{reqUser} = $self->current_user->{userid};
    $params->{treeid} = $self->param('treeid');
    $params->{rmUser} = $self->param('userid');
    
    my $json = AnnoTree::Model::Tree->removeUserFromTree($params);
    
    my $status = 204;
    if (exists $json->{error}) {
        $status = 406;
    }

    $self->render(json => $json, status => $status);
}

sub iosTokens {
    my $self = shift;

    my $jsonReq = $self->req->json;
    $self->render(json => {error => '0', txt => 'Missing JSON name/value pairs in request'}, status => 406) and return unless (exists $jsonReq->{tokens}); 
    
    $self->debug($self->dumper($jsonReq));
    my $tokens = $jsonReq->{tokens};
    $self->debug($self->dumper($tokens));

    my $json = AnnoTree::Model::Tree->iosTokens($tokens);

    $self->render(status => 200, json => $json);
}

return 1;
