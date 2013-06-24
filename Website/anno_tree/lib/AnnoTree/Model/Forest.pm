package AnnoTree::Model::Forest;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;

# Create a new forest 
sub create {
    my ($class, $params) = @_;
    
    print Dumper($params);
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
    if (looks_like_number($cols->[0])) { 
        # returns a 1 if user does not exist or was deleted
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Can\'t create a forest with a user that does not exist or was deleted'};
        }
    }
    my $forestInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $forestInfo->[$i];
    }
    
    return $json;
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

    my $json = {};
    my $index = 0;
    my $cols = $result->fetch;
    
    return {error => $cols->[0]} if (looks_like_number($cols->[0])); # returns a 1 if user does not exist or was deleted
    
    while (my $return = $result->fetch) {
        for (my $i = 0; $i < @{$cols}; $i++) {
            $json->{forests}->[$index]->{$cols->[$i]} = $return->[$i];
        }
        $index++;
    }
    
    return {error => 0} if ($index == 0); # return a one if there are no forests the user belongs to

    return $json;
}

return 1;
