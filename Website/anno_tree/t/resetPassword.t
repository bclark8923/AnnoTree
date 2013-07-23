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

#my $t = Test::Mojo->new('AnnoTree');
my $uaInvalidUser = Mojo::UserAgent->new;
my $json = Mojo::JSON->new; # use to help turn the response JSON into a Perl hash
my $tx; # this shuld be the Mojo::Transaction element return from the UA transaction
my $jsonBody; # this should be the body of the returned message if JSON
my $signupURL = $server . $port . '/user/signup';
my $resetURL = $server . $port . '/user/reset';

######### START VALID USER TEST #########
# this test creates a new valid user
my $testname = 'Valid user signup: ';
my $validUserEmail = 'mojotest' . int(rand(1000000)) . '@annotree.com';
my $validUserPass = 'tester1';
my $uaValidUser = Mojo::UserAgent->new;
$tx = $uaValidUser->post($signupURL => json => {
    signUpName      => 'test script user',
    signUpEmail     => $validUserEmail,
    signUpPassword  => $validUserPass
});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                               $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                              $testname . 'Response JSON ID exists');
ok('test script' eq $jsonBody->{first_name},            $testname . "Response JSON first name is 'test script'");
ok('user' eq $jsonBody->{last_name},                    $testname . "Response JSON last name is 'user'");
ok(exists $jsonBody->{created_at},                      $testname . 'Response JSON created date exists');
ok('ENG' eq $jsonBody->{lang},                          $testname . "Response JSON language is ENG");
ok(3 == $jsonBody->{status},                            $testname . 'Response JSON status is 3');
ok('EST' eq $jsonBody->{time_zone},                     $testname . "Response JSON time zone is EST");
ok('img/user.png' eq $jsonBody->{profile_image_path},   $testname . "Response JSON profile image path is img/user.png");
ok($validUserEmail eq $jsonBody->{email},               $testname . "Response JSON email is $validUserEmail");
######### END VALID USER TEST #########

######### START VALID USER PASSWORD RESET TEST #########
# this test requests to reset a password for a valid user
my $testname = 'Valid user reset password request: ';
$tx = $uaValidUser->post($resetURL => json => {
    email => $validUserEmail
});
$jsonBody = $json->decode($tx->res->body);

ok (204 == $tx->res->code, $testname . 'Reponse code is 204');
######### END VALID USER PASSWORD RESET TEST #########

done_testing();
