package AnnoTree::Controller::Auth;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::User;

# handles user signup
sub signup {
    my $self = shift;
    
    my $jsonReq = $self->req->json;
    
    # returns a 406 if the right parameters are not provided
    $self->render(json => {error => '0', txt => 'Fill out all required fields'}, status => 406) and return unless (exists $jsonReq->{signUpName} && exists $jsonReq->{signUpEmail} && exists $jsonReq->{signUpPassword});

    my $params = {};
    if ($jsonReq->{signUpName} =~ m/.*\s+\S+\Z/) {
        ($params->{'firstName'}, $params->{'lastName'}) = $jsonReq->{'signUpName'} =~ m/(.*)\s+(\S+)\Z/;
    } else {
        $jsonReq->{signUpName} =~ s/^\s*(.*?)\s*$//;
        $params->{lastName} = $1;
        $params->{firstName} = '';
    }
    $params->{'email'} = $jsonReq->{'signUpEmail'};
    $params->{'password'} = $jsonReq->{'signUpPassword'};
    
    my $json = AnnoTree::Model::User->signup($params);
    $self->render(json => $json, status => 406) and return if (exists $json->{error});
    
    # this should just authenticate the user without returning a 401 since the user was created successfully above
    $self->render(json => {error => '1', txt => 'Invalid email/password combination'}, status => 401) and return unless $self->authenticate($params->{email}, $params->{password});

    $self->render(json => $json);
}

# handles user login and sets the session
sub login {
    my $self = shift;

    my $jsonReq = $self->req->json;
    
    $self->render(json => {error => '0', txt => 'Fill out all required fields'}, status => 406) and return unless (exists $jsonReq->{loginEmail} && exists $jsonReq->{loginPassword});
    
    $self->render(json => {error => '1', txt => 'Invalid email/password combination'}, status => 401) and return unless $self->authenticate($jsonReq->{loginEmail}, $jsonReq->{loginPassword});
    
    my $json = AnnoTree::Model::User->getUserInfo($jsonReq->{loginEmail});
    
    my $status = 200;
    if (exists $json->{error}) { # user does not exist (this should never occur if the user has been authenticated above)
        $status = 406;
    }
    $self->render(json => $json, status => $status);
}

# verifies the user is authenticated
sub check {
    my $self = shift;
    if ($self->is_user_authenticated) {
        return 1;
    }
    #$self->redirect_to('/CCP/index.htm') and return 0;
    $self->render(json => {error => 0, txt => 'You are not authorized to access this service'}, status => 401) and return 0;
}

# destroys the user's session
sub logoutUser {
    my $self = shift;
    
    $self->logout();
    $self->render(json => {status => '0', txt => 'Logged out successfully'});
}

return 1;
