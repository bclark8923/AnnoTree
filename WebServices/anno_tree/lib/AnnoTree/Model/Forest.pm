package AnnoTree::Model::Forest;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);

# Create a new forest 
sub create {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_forest(:userid, :name, :desc)",
        {
            userid  => $params->{userid},
            name    => $params->{name},
            desc    => $params->{desc}
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    return {error => $cols->[0]} if (looks_like_number($cols->[0])); # returns a 1 if user does not exist or was deleted
    
    my $forestInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $forestInfo->[$i];
    }
    
    return $json;
}

# gets an individual forest's info from the DB
sub uniqueForest {
    my ($class, $id) = @_;
    
    #$self->debug("id is $id");

    my $result = AnnoTree::Model::MySQL->db->execute(
        "select id, name, description, created_at from forest where id = :pid",
        {
            pid => $id
        }
    );
    
    my $forest = {};
    my $res = $result->fetch;
    $forest->{id} = $res->[0];
    $forest->{name} = $res->[1];
    $forest->{description} = $res->[2];
    $forest->{created} = $res->[3];
    #$self->debug($self->dumper($res));
    #$self->debug($self->dumper($forest));
    
    return $forest; 
}

sub forestsForUser {
    my ($class, $params) = @_;
    
    #print 'Forest model userid: ' . $params->{userid};
 
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call get_forest_by_user(:userid)",
        {
            userid => $params->{userid}
        }
    );

    my $json = [];
    my $index = 0;
    my $cols = $result->fetch;
    while (my $return = $result->fetch) {
        #$controller->debug($controller->dumper($return));
        $json->[$index]->{id} = $return->[0];
        $json->[$index]->{name} = $return->[1];
        $json->[$index]->{description} = $return->[2];
        $json->[$index]->{createAt} = $return->[3];
        $index++;
    }
    
    return 1 if ($index == 0); # return a one if there are no forests the user belongs to

    return $json;
}

return 1;
