package AnnoTree::Model::MySQL;

use Mojo::Base -strict;
use DBIx::Custom;
use Data::Dumper;


my $DB;

sub init {
    my ($class, $config) = @_;

    my $dsn = 'dbi:mysql:database=' . $config->{database} . ';host=' . $config->{host} . ';port=' . $config->{port};
    
    $DB = DBIx::Custom->connect(
        dsn         => $dsn,
        user        => '' . $config->{username},
        password    => '' . $config->{password}
    ) or warn 'Could not connect to DB'; 

    return $DB;
}

sub db {
    return $DB if $DB;
}

# not using this
sub execute {
    my ($class, $query, $params) = @_;

    my $result = $class->db->execute($query, $params);
    my $return = [];
    my $index = 0;
    while (my $tuple = $result->fetch) {
        $return->[$index] = $tuple;
    }
    print "MYSQL------\n";
    print Dumper($return);
    return $return;
}

return 1;
