use Test::More;
use Mojo::UserAgent;
use Mojo::JSON;
use Config::General;

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;

my $server = $config{server}->{base_url};
my $port = ':3000';

my $ua= Mojo::UserAgent->new;
my $tx; # this shuld be the Mojo::Transaction element return from the UA transaction
my $signupURL = $server . $port . '/betasignup';

# this test signs up a beta user
my $testname = 'Beta signup 1: ';
$tx = $ua->post($signupURL => json => {
    email     => 'mattprice11@gmail.com'
});

ok(204 == $tx->res->code, $testname . 'Response Code is 204');

$tx = $ua->post($signupURL => json => {
    email     => 'bclark8923@gmail.com'
});

ok(204 == $tx->res->code, $testname . 'Response Code is 204');

done_testing();
