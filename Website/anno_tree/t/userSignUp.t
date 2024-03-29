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

######### START VALID USER TEST #########
# this test creates a new valid user
my $testname = 'Valid user signup: ';
my $validUserEmail = 'mojotest' . int(rand(1000000)) . '@user.com';
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

######### START VALID USER ONE NAME TEST #########
# this test creates a new valid user
my $testname = 'Valid user signup with one name: ';
my $validUserEmail = 'mojotest' . int(rand(1000000)) . '@user.com';
my $validUserPass = 'tester1';
my $uaValidUser = Mojo::UserAgent->new;
$tx = $uaValidUser->post($signupURL => json => {
    signUpName      => 'user',
    signUpEmail     => $validUserEmail,
    signUpPassword  => $validUserPass
});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                               $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                              $testname . 'Response JSON ID exists');
ok(exists $jsonBody->{first_name},                      $testname . "Response JSON first name is 'test script'");
ok('user' eq $jsonBody->{last_name},                    $testname . "Response JSON last name is 'user'");
ok(exists $jsonBody->{created_at},                      $testname . 'Response JSON created date exists');
ok('ENG' eq $jsonBody->{lang},                          $testname . "Response JSON language is ENG");
ok(3 == $jsonBody->{status},                            $testname . 'Response JSON status is 3');
ok('EST' eq $jsonBody->{time_zone},                     $testname . "Response JSON time zone is EST");
ok('img/user.png' eq $jsonBody->{profile_image_path},   $testname . "Response JSON profile image path is img/user.png");
ok($validUserEmail eq $jsonBody->{email},               $testname . "Response JSON email is $validUserEmail");
######### END VALID USER ONE NAME TEST #########

######### START MISSING REQUEST JSON VALUES TEST #########
# this test attempts to create a user with missing JSON values in the request
my $testname = 'Missing request parameters user signup: ';
$tx = $uaInvalidUser->post($signupURL => json => {
    signUpEmail     => 'mojotest@user.com',
    signUpPassword  => 'tester1'
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(0 == $jsonBody->{error},                     $testname . 'Response JSON error is 0');
ok(exists $jsonBody->{txt},                     $testname . 'Response JSON error text exists');
######### END MISSING REQUEST JSON VALUES TEST #########

######### START INVALID EMAIL TEST #########
# this test tries to create an user with an invalid email
my $testname = 'Invalid email user signup: ';
$tx = $uaInvalidUser->post($signupURL => json => {
    signUpName      => 'test script user',
    signUpEmail     => 'mojotest@u.c',
    signUpPassword  => 'tester1'
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(1 == $jsonBody->{error},                     $testname . 'Response JSON error is 1');
ok(exists $jsonBody->{txt},                     $testname . 'Response JSON error text exists');
######### END INVALID EMAIL TEST #########

######### START EXISTING EMAIL TEST #########
# this test attempts to signup an user who already exists
my $testname = 'Existing email user signup: ';
$tx = $uaInvalidUser->post($signupURL => json => {
    signUpName      => 'test script user',
    signUpEmail     => $validUserEmail,
    signUpPassword  => $validUserPass
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(2 == $jsonBody->{error},                     $testname . 'Response JSON error is 2');
ok(exists $jsonBody->{txt},                     $testname . 'Response JSON error text exists');
######### END EXISTING EMAIL TEST #########

######### START SHORT PASSWORD LENGTH TEST #########
# this test has a password that is not 6 characters in length
my $testname = 'Password too short user signup: ';
$tx = $uaInvalidUser->post($signupURL => json => {
    signUpName      => 'test script user',
    signUpEmail     => 'mojotest@user.com',
    signUpPassword  => 'test'
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(3 == $jsonBody->{error},                     $testname . 'Response JSON error is 3');
ok(exists $jsonBody->{txt},                     $testname . 'Response JSON error text exists');
######### END SHORT PASSWORD LENGTH TEST #########

######### START MISSING NUMBER IN PASSWORD TEST #########
# this test does not include a numeric character in the password
my $testname = 'Password missing number: ';
$tx = $uaInvalidUser->post($signupURL => json => {
    signUpName      => 'test script user',
    signUpEmail     => 'mojotest@user.com',
    signUpPassword  => 'tester'
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(4 == $jsonBody->{error},                     $testname . 'Response JSON error is 4');
ok(exists $jsonBody->{txt},                     $testname . 'Response JSON error text exists');
######### END MISSING NUMBER IN PASSWORD TEST #########

######### START INVALID CHARACTER IN PASSWORD TEST #########
# this test includes an invalid character in the password
my $testname = 'Password includes an invalid character: ';
$tx = $uaInvalidUser->post($signupURL => json => {
    signUpName      => 'test script user',
    signUpEmail     => 'mojotest@user.com',
    signUpPassword  => 'tester;6'
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(5 == $jsonBody->{error},                     $testname . 'Response JSON error is 5');
ok(exists $jsonBody->{txt},                     $testname . 'Response JSON error text exists');
######### END INVALID CHARACTER IN PASSWORD TEST #########

=begin oldtests
# Test that the signup form exists
$t->get_ok('/user/signup')
    ->status_is(200)
    ->element_exists('form input[name="signUpName"]')
    ->element_exists('form input[name="signUpEmail"]')
    ->element_exists('form input[name="signUpPassword"]')
    ->element_exists('form input[type="submit"]');

# Test that a valid signup submission works
$t->post_ok('/user/signup' => form => {signUpName => 'Mojo Test', signUpEmail => 'test@mojo.com', signUpPassword => 'password'})
    ->status_is(200)
    ->json_is({jsonBody => '0'});

# Test that if an user is already signed up that they are not signed up again
$t->post_ok('/user/signup' => form => {signUpName => 'Mojo Test', signUpEmail => 'test@mojo.com', signUpPassword => 'password'})
    ->status_is(200)
    ->json_is({jsonBody => '2'});

# Test that an invalid email will not be accepted
$t->post_ok('/user/signup' => form => {signUpName => 'Mojo Test', signUpEmail => 'c', signUpPassword => 'password'})
    ->status_is(200)
    ->json_is({jsonBody => '1'});

# Test that a login form exists
$t->get_ok('/user/login')
    ->status_is(200)
    ->element_exists('form input[name="loginEmail"]')
    ->element_exists('form input[name="loginPassword"]')
    ->element_exists('form input[type="submit"]');

# Test a invalid email for logging in
$t->post_ok('/user/login' => form => {loginEmail => 'invalid@test.com', loginPassword => 'password'})
    ->status_is(200)
    ->json_is({userid => '-1'});

# Test a valid email but invalid password for logging in
$t->post_ok('/user/login' => form => {loginEmail => 'test@mojo.com', loginPassword => 'invalidpassword'})
    ->status_is(200)
    ->json_is({userid => '0'});

# Test a valid email and valid password for logging in
$t->post_ok('/user/login' => form => {loginEmail => 'test@mojo.com', loginPassword => 'password'})
    ->status_is(200)
    ->json_has({email => 'test@mojo.com'}); # this is not working correctly - need to identify that this specific element exists
=end oldtests
=cut

done_testing();
