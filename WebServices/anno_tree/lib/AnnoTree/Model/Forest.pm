package AnnoTree::Model::Forest;

use EV;
use DBIx::Custom;

use strict;
use warnings;

# Create a new forest 
sub create {
    my ($self, $params) = @_;
    
    # need to change this so that we grab the actaul userid
    my $result = $self->db_dbi->execute(
        "select create_forest(:userid, :name, :desc)",
        {
            userid  => $params->{userid},
            name    => $params->{name},
            desc    => $params->{desc}
        }
    );

    my $json = {};
    $json->{result} = $result->fetch->[0];
    return $json;
}

# grabs all of the forests from the DB
sub getAllForests {
    my $self = shift;
    
    my $result = $self->db_dbi->execute(
        "select id, name, description, created_at from forest"
    );
    my $count = 0;
    my $forests = {};
    while (my $res = $result->fetch) {
        $forests->{forests}->[$count]->{id} = $res->[0];
        $forests->{forests}->[$count]->{name} = $res->[1];
        $forests->{forests}->[$count]->{description} = $res->[2];
        $forests->{forests}->[$count]->{created} = $res->[3];
        $count++;
    }
    #$self->debug($count);
    $forests->{numForests} = "$count";
    $self->debug($self->dumper($forests));
    
    return $forests;
}

# gets an individual forest's info from the DB
sub uniqueForest {
    my ($self, $id) = @_;
    
    $self->debug("id is $id");

    my $result = $self->db_dbi->execute(
        "select id, name, description, created_at from forest where id = :pid",
        {pid => $id}
    );
    
    my $forest = {};
    my $res = $result->fetch;
    $forest->{id} = $res->[0];
    $forest->{name} = $res->[1];
    $forest->{description} = $res->[2];
    $forest->{created} = $res->[3];
    $self->debug($self->dumper($res));
    $self->debug($self->dumper($forest));
    
    return $forest; 
}

sub forestsForUser {
    my ($controller, $params) = @_;
=begin oldcode
    my $select = $controller->db_dbi->execute(
        "select id, name, description, created_at
        from forest
        where id in (
            select forest_id
            from user_forest
            where user_id = :userid
        )",
        {
            userid => $params->{userid}
        }
    );
=end oldcode
=cut
    
    my $select = $controller->db_dbi->execute(
        "call get_forest_by_user(:userid)",
        {
            userid => $params->{userid}
        }
    );

    my $json = {};
    my $index = 0;
    while (my $return = $select->fetch) {
        $controller->debug($controller->dumper($return));
        $json->{forests}->[$index]->{id} = $return->[0];
        $json->{forests}->[$index]->{name} = $return->[1];
        $json->{forests}->[$index]->{description} = $return->[2];
        $json->{forests}->[$index]->{createAt} = $return->[3];
        $index++;
    }
    
    $json->{numForests} = '' . $index;
    return $json;
}

return 1;
