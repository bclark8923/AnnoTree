package AnnoTree::Model::Leaf;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;

sub create {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_leaf(:name, :desc, :userid, :branchid)",
        {
            userid      => $params->{userid},
            branchid    => $params->{branchid},
            name        => $params->{name},
            desc        => $params->{desc},
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    
    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Can\'t create a leaf with a user that is not active'};
        } elsif ($error == 2) { 
            return {error => $error, txt => 'Branch does not exist'};
        } 
    }
    my $leafInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $leafInfo->[$i];
    }
    
    return $json;
}

return 1;
