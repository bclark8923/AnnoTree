package AnnoTree::Model::Leaf;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use AnnoTree::Model::Email;
use Scalar::Util qw(looks_like_number);
use AnnoTree::Model::Email;
use Data::Dumper;
use MIME::Base64;

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;
my $path = $config{server}->{'annotationpath'};
my $confCCP = $config{server}->{base_url};
my $confSplash = $config{server}->{splash_url};

sub create {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_leaf(:name, :userid, :branchid)",
        {
            userid      => $params->{userid},
            branchid    => $params->{branchid},
            name        => $params->{name},
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    
    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'You do not have permissions to create a leaf on this branch'};
        } elsif ($error == 2) { 
            return {error => $error, txt => 'Branch does not exist'};
        } 
    }
    my $leafInfo = $result->fetch;
    for (my $i = 0; $i < @{$cols}; $i++) {
        if ($cols->[$i] eq 'priority') {
            $json->{$cols->[$i]} = $leafInfo->[$i] + 0;
        } else {
            $json->{$cols->[$i]} = $leafInfo->[$i];
        }
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

sub rename {
    my ($class, $params, $path) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call rename_leaf(:leafid, :name, :reqUser)",
        {
            leafid          => $params->{leafid},
            name            => $params->{name},
            reqUser         => $params->{reqUser},
        }
    );

    my $json = {};
    my $num = $result->fetch->[0];
    if ($num == 0) {
        $json = {result => $num, txt => 'Task updated successfully'};
    } elsif ($num == 1) {
        $json = {error => $num, txt => 'Leaf does not exist'};
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

sub changeBranch {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call leaf_change_branch(:user, :treeid, :branchid, :leafid)",
        {
            user        => $params->{user},
            treeid      => $params->{treeid},
            branchid    => $params->{branchid},
            leafid      => $params->{leafid},
        }
    );

    my $num = $result->fetch->[0];
    if ($num == 1) {
        return {error => '1', txt => 'You do not have permissions on that tree'};
    } elsif ($num == 2) {
        return {error => '2', txt => 'Branch does not exist'};
    }

    return {};
}

sub changeSubBranch {
    my ($class, $params) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call leaf_change_sub_branch(:user, :treeid, :newBranchid, :leafid, :oldBranchid, :newPriority, :oldPriority)",
        {
            user        => $params->{user},
            treeid      => $params->{treeid},
            newBranchid => $params->{newBranchid},
            leafid      => $params->{leafid},
            oldBranchid => $params->{oldBranchid},
            newPriority => $params->{newPriority},
            oldPriority => $params->{oldPriority},
        }
    );

    my $num = $result->fetch->[0];
    if ($num == 1) {
        return {error => '1', txt => 'You do not have permissions on that tree'};
    } elsif ($num == 2) {
        return {error => '2', txt => 'Branch does not exist'};
    }

    return {};
}

sub assign {
    my ($class, $params) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call assign_to_leaf(:reqUser, :leafid, :assign)",
        {
            reqUser     => $params->{reqUser},
            leafid      => $params->{leafid},
            assign      => $params->{assign},
        }
    );
    

    my $cols = $result->fetch;
    if (looks_like_number($cols->[0])) { 
        my $num = $cols->[0];
        if ($num == 1) {
            return {error => '1', txt => 'You do not have permissions on that tree'};
        } elsif ($num == 2) {
            return {error => '2', txt => 'Assigned user does not have permissions on that tree'};
        } elsif ($num == 3) {
            return {error => '3', txt => 'User has already been assigned to that leaf'};
        }
    } elsif ($params->{reqUser} != $params->{assign}) {
        # values: 'req_user_fname', 'req_user_lname', 'assign_fname', 'assign_lname', 'assign_status', 'assign_email', 'assign_notf_leaf_assign', 'forest_id', 'tree_id', 'branch_id', 'leaf_id', 'leaf_name'
        my $values = $result->fetch;
        my %info;
        for (my $i = 0; $i < @{$cols}; $i++) {
            $info{$cols->[$i]} = $values->[$i];
        }
        print Dumper(\%info);
        if ($info{assign_notf_leaf_assign} == 1) {
            my $to = $info{assign_email};
            my $from = '"AnnoTree" <invite@annotree.com>';
            my $subject = 'You Were Assigned To A Leaf';
            my $body = 'Hi';
            if ($info{assign_status} == 3) {
                $body .= ' ';
                $body .= $info{assign_fname} || $info{assign_lname};
                $body .= ',<p>';
                $info{req_user_fname} ? $body .= $info{req_user_fname} . ' ' : '';
                $body .= $info{req_user_lname} . ' assigned you to "' . $info{leaf_name} . '".</p>';
                $body .= 'You can view this leaf via the button below:<p>';
                $body .= '<table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">';
                $body .= '<tbody><tr><td style="padding-top:0;padding-right:18px;padding-bottom:18px;padding-left:18px" valign="top" align="center">';
                $body .= '<table border="0" cellpadding="0" cellspacing="0" style="border-top-left-radius:5px;border-top-right-radius:5px;border-bottom-right-radius:5px;border-bottom-left-radius:5px;background-color:#5cc080;border-collapse:collapse">';
                $body .= '<tbody><tr>';
                $body .= '<td align="center" valign="middle" style="font-family:Arial;font-size:18px;padding:20px">';
                $body .= '<a title="View Leaf" href="' . $confCCP . '/#/app/' . $info{forest_id} . '/' . $info{tree_id} . '/' . $info{branch_id} . '/' . $info{leaf_id} . '" style="font-weight:bold;letter-spacing:-0.5px;line-height:100%;text-align:center;text-decoration:none;color:#ffffff;word-wrap:break-word" target="_blank">View Leaf</a>';
                $body .= '</td></tr></tbody></table></td></tr></tbody></table>';
            } else {
                $body .= ',<p>';
                $info{req_user_fname} ? $body .= $info{req_user_fname} . ' ' : '';
                $body .= $info{req_user_lname} . ' assigned you to "' . $info{leaf_name} . '".</p>';
                $body .= '<p>Sign up and view this leaf by clicking the button below.  You can always learn more AnnoTree by visiting <a href="' . $confSplash . '">' . $confSplash . '</a>.</p>';
                $body .= '<table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">';
                $body .= '<tbody><tr><td style="padding-top:0;padding-right:18px;padding-bottom:18px;padding-left:18px" valign="top" align="center">';
                $body .= '<table border="0" cellpadding="0" cellspacing="0" style="border-top-left-radius:5px;border-top-right-radius:5px;border-bottom-right-radius:5px;border-bottom-left-radius:5px;background-color:#5cc080;border-collapse:collapse">';
                $body .= '<tbody><tr>';
                $body .= '<td align="center" valign="middle" style="font-family:Arial;font-size:18px;padding:20px">';
                $body .= '<a title="Signup Now!" href="' . $confCCP . '/#/authenticate/signUp?email=' . $info{assign_email} . '" style="font-weight:bold;letter-spacing:-0.5px;line-height:100%;text-align:center;text-decoration:none;color:#ffffff;word-wrap:break-word" target="_blank">Signup Now!</a>';
                $body .= '</td></tr></tbody></table></td></tr></tbody></table>';
            }
            AnnoTree::Model::Email->mail($to, $from, $subject, $body);
        }
    }

    return {};
}

sub assignRemove {
    my ($class, $params) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call remove_leaf_assignment(:reqUser, :leafid, :remove)",
        {
            reqUser     => $params->{reqUser},
            leafid      => $params->{leafid},
            remove      => $params->{remove},
        }
    );

    my $num = $result->fetch->[0];
    if ($num == 1) {
        return {error => '1', txt => 'You do not have permissions on that tree'};
    }

    return {};
}

return 1;
