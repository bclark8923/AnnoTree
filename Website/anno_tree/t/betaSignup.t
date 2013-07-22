use Test::More;
use Mojo::UserAgent;
use Data::Dumper;
use Mojo::JSON;
use Config::General;

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;

my $server = $config{server}->{base_url};
my $port = ':' . $config{server}->{'port'};

my $json = Mojo::JSON->new; # use to help turn the response JSON into a Perl hash
my $tx; # this shuld be the Mojo::Transaction element return from the UA transaction
my $jsonBody; # this should be the body of the returned message if JSON
my $signupURL = $server . $port . '/user/beta';
my $ua = Mojo::UserAgent->new;

######### START VALID BETA USER TEST #########
# this test creates a new valid beta user
my $testname = 'Valid beta user signup: ';
my $validBetaEmail = 'mojotest' . int(rand(1000000)) . '@annotree.com';
$tx = $ua->post($signupURL => json => {
    email => $validBetaEmail
});
$jsonBody = $json->decode($tx->res->body);

ok(204 == $tx->res->code, $testname . 'Response Code is 204');
######### END VALID BETA USER TEST #########

######### START DUPLICATE BETA USER TEST #########
# this test creates a new valid beta user
my $testname = 'Duplicate beta user signup: ';
$tx = $ua->post($signupURL => json => {
    email => $validBetaEmail
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,       $testname . 'Response Code is 406');
ok(4 == $jsonBody->{error},     $testname . 'Response JSON error is 4');
ok(exists $jsonBody->{txt},     $testname . 'Response JSON text exists');
######### END DUPLICATE BETA USER TEST #########

done_testing();
