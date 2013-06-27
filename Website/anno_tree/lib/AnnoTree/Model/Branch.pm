package AnnoTree::Model::Branch;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;

sub create {
    my ($class, $params) = @_;
    
    print Dumper($params);
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_branch(:userid, :treeid, :name, :desc)",
        {
            userid      => $params->{userid},
            treeid      => $params->{treeid},
            name        => $params->{name},
            desc        => $params->{desc},
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Can\'t create a tree with a user that is not active'};
        } elsif ($error == 2) { 
            return {error => $error, txt => 'Tree does not exist'};
        } 
    }
    my $branchInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $branchInfo->[$i];
    }
    
    return $json;
}

return 1;
