package AnnoTree::Model::Comments;

use Mojo::Base -strict;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);

#TODO: truncate length of comment 2048 check length in angular
sub leafCreate {
    my ($class, $params) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_leaf_comment(:userid, :comment, :leafid)",
        {
            userid        => $params->{userid},
            comment      => $params->{comment},
            leafid      => $params->{leafid},
        }
    );

    my $json = {};
    my $cols = $result->fetch;

    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Tree, branch, or leaf does not exist or user does not have access to that tree'};
        }
    }

    my $commentIndex = 0;
    while (my $comment = $result->fetch) {
        $json->{comments} = [] if $commentIndex == 0;
        for (my $i = 0; $i < @{$cols}; $i++) {
            $json->{comments}->[$commentIndex]->{$cols->[$i]} = $comment->[$i];
        }
        $commentIndex++;
    }
    
    return $json;
}

sub leafInfo {
    my ($class, $params) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call get_leaf_comments(:userid, :leafid)",
        {
            leafid  => $params->{leafid},
            userid  => $params->{userid}
        }
    );

    my $json = {};
    my $cols = $result->fetch;

    if (looks_like_number($cols->[0])) { 
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Tree, branch, or leaf does not exist or user does not have access to that tree'};
        }
    }

    my $commentIndex = 0;
    while (my $comment = $result->fetch) {
        $json->{comments} = [] if $commentIndex == 0;
        for (my $i = 0; $i < @{$cols}; $i++) {
            $json->{comments}->[$commentIndex]->{$cols->[$i]} = $comment->[$i];
        }
        $commentIndex++;
    }
    
    return $json;
}

return 1;
