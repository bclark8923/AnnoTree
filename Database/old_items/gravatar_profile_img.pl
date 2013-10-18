#! /usr/bin/env perl

use DBIx::Custom;
use Config::General;
use Gravatar::URL;

use strict;
use warnings;

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;

# Database set up
my $dsn = 'dbi:mysql:database=annotree;host=' . $config{database}->{server} . ';port=' . $config{database}->{port};

my $db = DBIx::Custom->connect(
    dsn         => $dsn,
    user        => 'annotree',
    password    => 'ann0tr33s',
    connector   => 1
) or die 'Could not connect to DB';

$db->{mysql_auto_reconnect} = 1;

my $users = $db->execute(
    "select id, email from user"
);

while (my $user = $users->fetch) {
    my %options = (
        default => 'wavatar', 
        rating  => 'pg',
        https   => 1
    );

    $db->execute(
        "update user set profile_image_path = :path where id = :id", 
        {
            path    => gravatar_url(email => $user->[1], %options),
            id      => $user->[0]
        }
    );
}
