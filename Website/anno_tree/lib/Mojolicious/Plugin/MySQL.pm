package Mojolicious::Plugin::MySQL;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Base -strict;
use DBIx::Custom;
use EV;

use Data::Dumper;

# pieces taken from:
# https://github.com/benvanstaveren/Mojolicious-Plugin-Database/blob/master/lib/Mojolicious/Plugin/Database.pm
# https://github.com/kraih/mojo/wiki/Non-blocking-mysql

sub register {
    my ($self, $app, $settings) = @_;
    
    for my $key (keys(%{$settings})) {
        #say "key is " . $key;
        $self->initialize($app, $key, $settings->{$key});
    }
}

sub initialize {
    my ($self, $app, $helperPrefix, $settings) = @_;

    die ref($self), ' - database settings are not a hash reference', "\n" unless(ref($settings) eq 'HASH');

    #say 'intializing db';
    #say Dumper($settings);

    my $dsn = 'dbi:mysql:database=' . $settings->{database} . ';host=' . $settings->{host} . ';port=' . $settings->{port};
    

    my $attr_name = '_dbh_' . $helperPrefix;
    $app->attr($attr_name => sub {
            DBIx::Custom->connect(
                dsn         => $dsn,
                user        => '' . $settings->{username},
                password    => '' . $settings->{password} 
            );
        });

    $app->helper($helperPrefix . '_dbi' => sub { return shift->app->$attr_name(); });
    $app->helper($helperPrefix . '_test' => \&testStr);
}

sub setDB {
    my ($self) = @_;

    $self->app->log->debug('testing DB poop');
}

sub testStr {
    my ($self, $str) = @_;
    $self->db_dbi->execute( #$dbi->execute(
        "select create_user(:password, :firstName, :lastName, :email, :lang, :timezone, :profileImage)",
        {
            email           => 'testing@test.com',
            password        => 'madeup',
            firstName       => 'me',
            lastName        => 'you',
            lang            => "ENG",
            timezone        => "EST",
            profileImage    => "NULL"
        }
    );
    $self->app->log->debug($str);
}

return 1;
