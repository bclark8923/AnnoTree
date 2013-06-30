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

sub leafInfo {
    my ($class, $params) = @_;
    
    my $json = {};
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call get_leaf(:userid, :leafid)",
        {
            userid  => $params->{userid},
            leafid  => $params->{leafid}
        }
    ); 
    
    my $cols = $result->fetch;
    return {error => '1', txt => 'Leaf does not exist or user does not have access'} if (looks_like_number($cols->[0]));
    my $leafInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $leafInfo->[$i];
    }

    $json->{annotations} = [];
    my $annoResult = AnnoTree::Model::MySQL->db->execute(
        'call get_annotation(:leafid)',
        {
            leafid => $json->{id}
        }
    );
    my $annoCols = $annoResult->fetch;
    unless (looks_like_number($annoCols->[0])) {
        my $annoIndex = 0;
        while (my $anno = $annoResult->fetch) {
            for (my $i = 0; $i < @{$annoCols}; $i++) {
                $json->{annotations}->[$annoIndex]->{$annoCols->[$i]} = $anno->[$i]; 
            }
            $annoIndex++;
        }
    }

    return $json;
}

sub iosUpload {
    my ($class, $params) = @_;
    
    my $json = {};
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_leaf_on_tree(:token, :leafname)",
        {
            token       => $params->{token},
            leafname    => 'iOS Screenshot'
        }
    ); 
    
    my $cols = $result->fetch;
    if (looks_like_number($cols->[0])) {
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Tree does not exist'};
        } elsif ($error == 2) {
            return {error => $error, txt => 'No branches exist'};
        }
    }
    my $leafInfo = $result->fetch;
    my $leafid = $leafInfo->[0];
    my $fsName = $leafid . '_' . $params->{filename};
    my $annoResult = AnnoTree::Model::MySQL->db->execute(
        "call create_annotation(:mime, :path, :filename, :leafid)",
        {
            mime        => $params->{mime},
            path        => $params->{path} . $fsName,
            filename    => $params->{filename},
            leafid      => $leafid
        }
    );

    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => '3', txt => 'Can\'t create a annotation on a leaf that does not exist'};
        }
    }
    
    return {fsName => $fsName};
}

return 1;
