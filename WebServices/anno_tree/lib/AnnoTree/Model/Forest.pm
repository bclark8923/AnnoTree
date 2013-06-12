package AnnoTree::Model::Forest;

use EV;
use DBIx::Custom;

use strict;
use warnings;

my $dbi = DBIx::Custom->connect(
    dsn         => 'dbi:mysql:database=annotree;host=localhost;port=3306',
    user        => 'annotree',
    password    => 'ann0tr33s'
);

# need to make this fully async but that can come later
$dbi->async_conf({
    prepare_attr    => {async => 1},
    fh              => sub {shift->dbh->mysql_fd}
});

# grabs all of the forests from the DB
sub getAllForests {
    my $self = shift;
    
    my $result = $dbi->execute(
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
sub getUniqueForest {
    my ($self, $id) = @_;
    
    $self->debug("id is $id");

    my $result = $dbi->execute(
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

return 1;
