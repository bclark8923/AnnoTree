package AnnoTree::Model::Leaf;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;
use MIME::Base64;

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;
my $path = $config{server}->{'annotationpath'};

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
    
    $json->{comments} = [];
    my $commentsResult = AnnoTree::Model::MySQL->db->execute(
        "call get_leaf_comments(:userid, :leafid)",
        {
            leafid  => $params->{leafid},
            userid  => $params->{userid}
        }
    );
    my $commentCols = $commentsResult->fetch;
    unless (looks_like_number($commentCols->[0])) { 
        my $commentIndex = 0;
        while (my $comment = $commentsResult->fetch) {
            for (my $i = 0; $i < @{$commentCols}; $i++) {
                $json->{comments}->[$commentIndex]->{$commentCols->[$i]} = $comment->[$i];
            }
            $commentIndex++;
        }
    }
    
    return $json;
}

sub update {
    my ($class, $params, $path) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call update_leaf(:leafid, :name, :desc, :reqUser, :branchid)",
        {
            leafid          => $params->{leafid},
            name            => $params->{name},
            desc            => $params->{desc},
            reqUser         => $params->{reqUser},
            branchid        => $params->{branchid}
        }
    );

    my $json = {};
    my $num = $result->fetch->[0];
    if ($num == 0) {
        $json = {result => $num, txt => 'Task updated successfully'};
    } elsif ($num == 1) {
        $json = {result => $num, txt => 'Nothing was changed'};
    } elsif ($num == 2) {
        $json = {error => $num, txt => 'Leaf does not exist'};
    } elsif ($num == 3) {
        $json = {error => $num, txt => 'Requesting user does not exist or does not have access to the tree'};
    } elsif ($num == 4) {
        $json = {error => $num, txt => 'Branch does not exist or is not within the same tree as the leaf you are trying to update'};
    }

    return $json;
}

sub iosUpload {
    my ($class, $params, $path) = @_;
    
    my $json = {};
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_leaf_on_tree(:token, :leafname)",
        {
            token       => $params->{token},
            leafname    => $params->{leafName}
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
    my $annoResult = AnnoTree::Model::MySQL->db->execute(
        "call create_annotation(:mime, :path, :filename, :leafid, :metaSystem, :metaVersion, :metaModel, :metaVendor, :metaOrientation)",
        {
            mime            => $params->{mime},
            path            => $params->{path},
            filename        => $params->{filename},
            leafid          => $leafid,
            metaSystem      => $params->{metaSystem},
            metaVersion     => $params->{metaVersion},
            metaModel       => $params->{metaModel},
            metaVendor      => $params->{metaVendor},
            metaOrientation => $params->{metaOrientation},

        }
    );

    $cols = $annoResult->fetch;
    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => '3', txt => 'Can\'t create a annotation on a leaf that does not exist'};
        }
    }
    my $annoInfo = $annoResult->fetch;
    
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $annoInfo->[$i] if $cols->[$i];
    }

    #TODO: use perl plugin
    my ($diskDir) = $json->{filename_disk} =~ m{(.*)/};
    my @dir = split(/\//, $diskDir);
    `mkdir $path/$dir[0]` unless (-d "$path/$dir[0]");
    `mkdir $path/$dir[0]/$dir[1]` unless (-d "$path/$dir[0]/$dir[1]");
    `mkdir $path/$dir[0]/$dir[1]/$dir[2]` unless (-d "$path/$dir[0]/$dir[1]/$dir[2]");
    
    return $json;
}

sub chromeUpload {
    my ($class, $params, $path) = @_;
    
    my $json = {};
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_leaf_on_tree_owner(:token, :leafName, :owner)",
        {
            token       => $params->{token},
            leafName    => $params->{leafName},
            owner       => $params->{owner}
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
    my $annoResult = AnnoTree::Model::MySQL->db->execute(
        "call create_annotation_with_owner(:mime, :path, :filename, :leafid, :metaSystem, :metaVersion, :metaModel, :metaVendor, :metaOrientation, :owner, :site)",
        {
            mime            => $params->{mime},
            path            => $params->{path},
            filename        => $params->{filename},
            leafid          => $leafid,
            metaSystem      => $params->{metaSystem},
            metaVersion     => $params->{metaVersion},
            metaModel       => $params->{metaModel},
            metaVendor      => $params->{metaVendor},
            metaOrientation => $params->{metaOrientation},
            owner           => $params->{owner},
            site            => $params->{site},
        }
    );

    $cols = $annoResult->fetch;
    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => '3', txt => 'Can\'t create a annotation on a leaf that does not exist'};
        }
    }
    my $annoInfo = $annoResult->fetch;
    
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $annoInfo->[$i] if $cols->[$i];
    }
    my ($diskDir) = $json->{filename_disk} =~ m{(.*)/};
    my @dir = split(/\//, $diskDir);
    `mkdir $path/$dir[0]` unless (-d "$path/$dir[0]");
    `mkdir $path/$dir[0]/$dir[1]` unless (-d "$path/$dir[0]/$dir[1]");
    `mkdir $path/$dir[0]/$dir[1]/$dir[2]` unless (-d "$path/$dir[0]/$dir[1]/$dir[2]");
    my $decoded = decode_base64($params->{annotation});
    
    open my $fh, '>', "$path/$json->{filename_disk}";
    binmode $fh;
    print $fh $decoded;
    close $fh;
    delete $json->{filename_disk};
 
    return $json;
}

sub deleteLeaf {
    my ($class, $params) = @_;

    my $annoResult = AnnoTree::Model::MySQL->db->execute(
        "call get_annotations_files_by_leaf(:leafid)",
        {
            leafid => $params->{leafid}
        }
    );
    my $annoPath = '';
    my @files = ();
    while (my $return = $annoResult->fetch) {
        push(@files, $return->[0]);
    }
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call delete_leaf(:reqUser, :leafid)",
        {
            leafid          => $params->{leafid},
            reqUser         => $params->{reqUser}
        }
    );

    my $json = {};
    my $num = $result->fetch->[0];
    if ($num == 0) {
        for my $file (@files) {
            `rm $path/$file` if ($file ne 'anno_default.png' && defined $file);
        }
    } elsif ($num == 1) {
        $json = {error => $num, txt => 'Nothing was deleted'};
    } elsif ($num == 2) {
        $json = {error => $num, txt => 'Leaf does not exist or user does not have permissions to delete leaf'};
    }

    return $json;
}

return 1;
