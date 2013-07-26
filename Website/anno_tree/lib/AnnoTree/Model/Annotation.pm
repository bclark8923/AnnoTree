package AnnoTree::Model::Annotation;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;

sub create {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_annotation(:mime, :path, :filename, :leafid, :metaSystem, :metaVersion, :metaModel, :metaVendor, :metaOrientation)",
        {
            mime            => $params->{mime},
            path            => $params->{path},
            filename        => $params->{filename},
            leafid          => $params->{leafid},
            metaSystem      => $params->{metaSystem},
            metaVersion     => $params->{metaVersion},
            metaModel       => $params->{metaModel},
            metaVendor      => $params->{metaVendor},
            metaOrientation => $params->{metaOrientation},
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    
    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Can\'t create a annotation on a leaf that does not exist'};
        }
    }
    my $annoInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $annoInfo->[$i] if $cols->[$i];
    }
    
    return $json;
}

sub getImage {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call access_annotation(:user, :annoid)",
        {
            user    => $params->{userid},
            annoid  => $params->{annoid}
        }
    ); 

    return $result->fetch;
}

return 1;
