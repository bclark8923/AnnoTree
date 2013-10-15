package AnnoTree::Controller::User;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::User;
use Scalar::Util qw(looks_like_number);
use Email::Valid;

sub deleteUser {
    my $self = shift;

    my $userid = $self->param('userid');

    my $result = AnnoTree::Model::User->deleteUser($userid);
    
    my $status = 200;
    $status = 404 if (exists $result->{error});

    $self->render(json => $result, status => $status);
}

sub knownPeople {
    my $self = shift;

    my $user = $self->current_user->{userid};

    my $json = AnnoTree::Model::User->knownPeople($user);

    $self->render(json => $json, status => 200);
}

# beta signup service
sub beta {
    my $self = shift;
    
    my $jsonReq = $self->req->json;
    my $email = $jsonReq->{email};
    
    my $json = AnnoTree::Model::User->beta($email);

    my $status = 204;
    $status = 406 if (exists $json->{error});

    $self->render(json => $json, status => $status);
}

sub feedback {
    my $self = shift;

    my $jsonReq = $self->req->json;

    my $params = {};
    $params->{userid} = $self->current_user->{userid};
    $params->{feedback} = $jsonReq->{feedback};

    AnnoTree::Model::User->feedback($params);

    $self->render(status => 204, text => "Success");
}

# let's an user apply to reset their password
sub setReset {
    my $self = shift;

    my $jsonReq = $self->req->json;
    my $email = $jsonReq->{email};
    
    my $json = AnnoTree::Model::User->setReset($email);
    
    my $status = 204;
    $status = 406 if (exists $json->{error});

    $self->render(status => $status, json => $json)
}

# resets an user's password
sub reset {
    my $self = shift;

    my $jsonReq = $self->req->json;
    my $params = {};
    $params->{password} = $jsonReq->{password};
    $params->{token} = $self->param('token');
    
    my $json = AnnoTree::Model::User->reset($params);
    
    my $status = 204;
    $status = 406 if (exists $json->{error});
    
    $self->render(status => $status, json => $json);
}

sub getUserInformation {
    my $self = shift;

    my $json = AnnoTree::Model::User->getUserInformation($self->current_user->{userid});

    $self->render(json => $json, status => 200);
}

sub loginTrees {
    my $self = shift;

    my $jsonReq = $self->req->json;
    $self->render(json => {error => '0', txt => 'Missing JSON name/value pairs in request'}, status => 406) and return unless (exists $jsonReq->{loginEmail} && exists $jsonReq->{loginPassword});

    my $params = {};
    $params->{email} = $jsonReq->{loginEmail};
    $params->{password} = $jsonReq->{loginPassword};

    my $json = AnnoTree::Model::User->loginTrees($params);
    
    my $status = 200;
    $status = 401 if (exists $json->{error});
    
    $self->render(status => $status, json => $json);
}

sub update {
    my $self = shift;

    my $jsonReq = $self->req->json;
    $self->render(json => {error => '0', txt => 'Missing JSON name/value pairs in request'}, status => 406) and return unless (exists $jsonReq->{name} && exists $jsonReq->{email});
    $self->render(json => {error => '2', txt => 'Please fill out your name'}, status => 406) and return unless ($jsonReq->{name} =~ m/[A-Za-z]/);
    $self->render(json => {error => '3', txt => 'Please enter a valid email'}, status => 406) and return unless (Email::Valid->address($jsonReq->{email}));

    my $params = {};
    if ($jsonReq->{name} =~ m/.*\s+\S+\Z/) {
        ($params->{firstName}, $params->{lastName}) = $jsonReq->{name} =~ m/(.*)\s+(\S+)\Z/;
    } else {
        $jsonReq->{name} =~ s/^\s*(.*?)\s*$//;
        $params->{lastName} = $1;
        $params->{firstName} = '';
    }
    $params->{email} = $jsonReq->{email};
    $params->{userid} = $self->current_user->{userid};

    my $json = AnnoTree::Model::User->update($params);
    
    my $status = 200;
    $status = 401 if (exists $json->{error});
    
    $self->render(status => $status, json => $json);
}

sub updatePassword {
    my $self = shift;

    my $jsonReq = $self->req->json;
    my $params = {};
    $params->{password} = $jsonReq->{password};
    $params->{userid} = $self->current_user->{userid};
    
    my $json = AnnoTree::Model::User->updatePassword($params);
    
    my $status = 204;
    $status = 406 if (exists $json->{error});
    
    $self->render(status => $status, json => $json);
}

sub notifications {
    my $self = shift;

    my $jsonReq = $self->req->json;
    $self->render(json => {error => '0', txt => 'Invalid submission'}, status => 406) and return unless ($jsonReq->{treeInvite} =~ m/[10]/ && $jsonReq->{leafAssign} =~ m/[10]/);

    my $params = {};
    $params->{treeInvite} = $jsonReq->{treeInvite};
    $params->{leafAssign} = $jsonReq->{leafAssign};
    $params->{userid} = $self->current_user->{userid};
    
    my $json = AnnoTree::Model::User->notifications($params);
    
    my $status = 204;
    $status = 406 if (exists $json->{error});
    
    $self->render(status => $status, json => $json);
}

return 1;
