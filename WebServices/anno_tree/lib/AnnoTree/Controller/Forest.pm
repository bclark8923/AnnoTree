package AnnoTree::Controller::Forest;

use Mojo::Base 'Mojolicious::Controller';
use AnnoTree::Model::Forest;

sub list {
    my $self = shift;
    
    my $model = AnnoTree::Model::Forest::getAllForests($self);

    #$self->debug($self->dumper($forests));
    $self->debug($self->dumper($model));

    $self->render(json => $model);
    #$self->render(text => "hello");
}

sub uniqueForest {
    my $self = shift;

    my $id = $self->param('id');

    $self->debug("before go id is $id");
    
    my $model = AnnoTree::Model::Forest::uniqueForest($self, $id);
    $self->render(json => $model);
}


sub create {
    my $self = shift;
    
    my $params = {};
    $params->{userid} = $self->param('userid');
    $params->{name} = $self->param('name');
    $params->{desc} = $self->param('description');
    
    my $result = AnnoTree::Model::Forest::create($self, $params);

    $self->render(json => $result);
}

# temporary route to test forest creation
sub testCreate {
    my $self = shift;

    $self->render(template => 'forest/testcreate');
}

sub forestsForUser {
    my $self = shift;

    my $params = {};
    $params->{userid} = $self->param('userid');

    my $result = AnnoTree::Model::Forest::forestsForUser($self, $params);

    $self->render(json => $result);
}

return 1;
