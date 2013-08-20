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
        password    => '' . $config->{password},
        connector   => 1
    ) or warn 'Could not connect to DB';
    
    $DB->{mysql_auto_reconnect} = 1;

    return $DB;
}

sub db {
    return $DB if $DB;
}

return 1;
