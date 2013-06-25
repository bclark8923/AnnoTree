use Test::More;
#use Test::Mojo;
use Mojo::UserAgent;
use Data::Dumper;
use Mojo::JSON;

#my $t = Test::Mojo->new('AnnoTree');
my $json = Mojo::JSON->new; # use to help turn the response JSON into a Perl hash
my $tx; # this shuld be the Mojo::Transaction element return from the UA transaction
my $jsonBody; # this should be the body of the returned message if JSON

######### START VALID USER SIGNUP TEST #########
# this test creates a new valid user
my $testname = 'Valid user signup: ';
my $validUserEmail = 'mojotest' . int(rand(1000000)) . '@user.com';
my $validUserPass = 'tester1';
my $uaValidSignUp = Mojo::UserAgent->new;
$tx = $uaValidSignUp->post('http://localhost:3000/user/signup' => json => {
    signUpName      => 'login test user',
    signUpEmail     => $validUserEmail,
    signUpPassword  => $validUserPass
});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                               $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                              $testname . 'Response JSON ID exists');
ok('login test' eq $jsonBody->{first_name},             $testname . "Response JSON first name is 'login test'");
ok('user' eq $jsonBody->{last_name},                    $testname . "Response JSON last name is 'user'");
ok(exists $jsonBody->{created_at},                      $testname . 'Response JSON created date exists');
ok('ENG' eq $jsonBody->{lang},                          $testname . "Response JSON language is ENG");
ok(1 == $jsonBody->{active},                            $testname . 'Response JSON active is 1');
ok('EST' eq $jsonBody->{time_zone},                     $testname . "Response JSON time zone is EST");
ok('img/user.png' eq $jsonBody->{profile_image_path},   $testname . "Response JSON profile image path is img/user.png");
ok($validUserEmail eq $jsonBody->{email},               $testname . "Response JSON email is 'mojotest\@user.com'");
######### END VALID USER SIGNUP TEST #########

######### START VALID USER LOGIN TEST #########
# this test logs on a valid user
my $testname = 'Valid user login: ';
my $uaValidLogin = Mojo::UserAgent->new;
$tx = $uaValidLogin->post('http://localhost:3000/user/login' => json => {
    loginEmail     => $validUserEmail,
    loginPassword  => $validUserPass
});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                               $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                              $testname . 'Response JSON ID exists');
ok('login test' eq $jsonBody->{first_name},             $testname . "Response JSON first name is 'test script'");
ok('user' eq $jsonBody->{last_name},                    $testname . "Response JSON last name is 'user'");
ok(exists $jsonBody->{created_at},                      $testname . 'Response JSON created date exists');
ok('ENG' eq $jsonBody->{lang},                          $testname . "Response JSON language is ENG");
ok(1 == $jsonBody->{active},                            $testname . 'Response JSON active is 1');
ok('EST' eq $jsonBody->{time_zone},                     $testname . "Response JSON time zone is EST");
ok('img/user.png' eq $jsonBody->{profile_image_path},   $testname . "Response JSON profile image path is img/user.png");
ok($validUserEmail eq $jsonBody->{email},               $testname . "Response JSON email is 'mojotest\@login.com'");
######### END VALID USER TEST #########

######### START VALID USER LOGOUT TEST #########
# this test logs on a valid user
my $testname = 'Valid user logout: ';
$tx = $uaValidLogin->post('http://localhost:3000/user/logout');
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                       $testname . 'Response Code is 200');
ok(0 == $jsonBody->{status},                    $testname . 'Response JSON status is 0');
ok(exists $jsonBody->{txt},                     $testname . 'Response JSON logout text exists');
######### START VALID USER LOGOUT TEST #########

######### START MISSING REQUEST JSON PARAMETERS TEST #########
# this test attempts to login an user with missing JSON values in the request
my $testname = 'Missing request parameters user login: ';
my $uaInvalidLogin = Mojo::UserAgent->new;
$tx = $uaInvalidLogin->post('http://localhost:3000/user/signup' => json => {
    signUpEmail => $validUserEmail
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(0 == $jsonBody->{error},                     $testname . 'Response JSON error is 0');
ok(exists $jsonBody->{txt},                     $testname . 'Response JSON error text exists');
######### END MISSING REQUEST JSON PARAMETERS TEST #########

######### START INVALID PASSWORD TEST #########
# this test attempts to login a valid user email but incorrect password
my $testname = 'Invalid password user login: ';
$tx = $uaInvalidLogin->post('http://localhost:3000/user/login' => json => {
    loginEmail     => $validUserEmail,
    loginPassword  => 'invalidpassword1'
});
$jsonBody = $json->decode($tx->res->body);

ok(401 == $tx->res->code,                       $testname . 'Response Code is 401');
ok(1 == $jsonBody->{error},                     $testname . 'Response JSON result is 1');
ok(exists $jsonBody->{txt},                     $testname . 'Response JSON error text exists');
######### END INVALID PASSWORD TEST #########

######### START INVALID EMAIL/USER TEST #########
# this test logs on a valid user
my $testname = 'Invalid user email login: ';
$tx = $uaInvalidLogin->post('http://localhost:3000/user/login' => json => {
    loginEmail     => 'mojotest@user.com',
    loginPassword  => 'invalidpassword1'
});
$jsonBody = $json->decode($tx->res->body);

ok(401 == $tx->res->code,                       $testname . 'Response Code is 401');
ok(1 == $jsonBody->{error},                     $testname . 'Response JSON result is 1');
ok(exists $jsonBody->{txt},                     $testname . 'Response JSON error text exists');
######### END INVALID EMAIL/USER TEST #########

done_testing();
