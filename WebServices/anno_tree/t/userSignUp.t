use Test::More;
use Test::Mojo;
use Mojo::UserAgent;
use Data::Dumper;
use Mojo::JSON;

#my $t = Test::Mojo->new('AnnoTree');
my $ua = Mojo::UserAgent->new; # use to make the JSON POST requests
my $json = Mojo::JSON->new; # use to help turn the response JSON into a Perl hash
my $tx; # this shuld be the Mojo::Transaction element return from the UA transaction
my $jsonBody; # this should be the body of the returned message if JSON

######### START VALID USER TEST #########
# this test creates a new valid user
my $testname = 'Valid user signup: ';
my $validUserEmail = 'mojotest' . int(rand(1000000)) . '@user.com';
my $validUserPass = 'tester1';
$tx = $ua->post('http://localhost:3000/user/signup' => json => {
    signUpName      => 'test script user',
    signUpEmail     => $validUserEmail,
    signUpPassword  => $validUserPass
});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                       $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                      $testname . 'Response JSON ID exists');
ok('test script' eq $jsonBody->{first_name},    $testname . "Response JSON first name is 'test script'");
ok('user' eq $jsonBody->{last_name},            $testname . "Response JSON last name is 'user'");
ok(exists $jsonBody->{created_at},              $testname . 'Response JSON created date exists');
ok('ENG' eq $jsonBody->{lang},                  $testname . "Response JSON language is ENG");
ok(1 == $jsonBody->{active},                    $testname . 'Response JSON active is 1');
ok('EST' eq $jsonBody->{time_zone},             $testname . "Response JSON time zone is EST");
ok(exists $jsonBody->{password},                $testname . 'Response JSON password exists');
ok('NULL' eq $jsonBody->{profile_image_path},   $testname . "Response JSON profile image path is NULL");
ok($validUserEmail eq $jsonBody->{email},       $testname . "Response JSON email is 'mojotest\@user.com'");
my $validUserID = $jsonBody->{id};
######### END VALID USER TEST #########

######### START MISSING REQUEST JSON PARAMETERS TEST #########
# this test attempts to send missing JSON parameters
my $testname = 'Missing request parameters user signup: ';
$tx = $ua->post('http://localhost:3000/user/signup' => json => {
    signUpEmail     => 'mojotest@user.com',
    signUpPassword  => 'tester1'
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(6 == $jsonBody->{error},                     $testname . 'Response JSON result is 6');
######### END MISSING REQUEST JSON PARAMETERS TEST #########

######### START INVALID EMAIL TEST #########
# this test creates a new valid user
my $testname = 'Invalid email user signup: ';
$tx = $ua->post('http://localhost:3000/user/signup' => json => {
    signUpName      => 'test script user',
    signUpEmail     => 'mojotest@u.c',
    signUpPassword  => 'tester1'
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(1 == $jsonBody->{error},                     $testname . 'Response JSON result is 1');
######### END INVALID EMAIL TEST #########

######### START EXISTING EMAIL TEST #########
# this test creates a new valid user
my $testname = 'Existing email user signup: ';
$tx = $ua->post('http://localhost:3000/user/signup' => json => {
    signUpName      => 'test script user',
    signUpEmail     => $validUserEmail,
    signUpPassword  => $validUserPass
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(2 == $jsonBody->{error},                     $testname . 'Response JSON result is 2');
######### END EXISTING EMAIL TEST #########

######### START SHORT PASSWORD LENGTH TEST #########
# this test creates a new valid user
my $testname = 'Password too short user signup: ';
$tx = $ua->post('http://localhost:3000/user/signup' => json => {
    signUpName      => 'test script user',
    signUpEmail     => 'mojotest@user.com',
    signUpPassword  => 'test'
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(3 == $jsonBody->{error},                     $testname . 'Response JSON result is 3');
######### END SHORT PASSWORD LENGTH TEST #########

######### START MISSING NUMBER IN PASSWORD TEST #########
# this test creates a new valid user
my $testname = 'Password too short user signup: ';
$tx = $ua->post('http://localhost:3000/user/signup' => json => {
    signUpName      => 'test script user',
    signUpEmail     => 'mojotest@user.com',
    signUpPassword  => 'tester'
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(4 == $jsonBody->{error},                     $testname . 'Response JSON result is 4');
######### END MISSING NUMBER IN PASSWORD TEST #########

######### START INVALID CHARACTER IN PASSWORD TEST #########
# this test creates a new valid user
my $testname = 'Password too short user signup: ';
$tx = $ua->post('http://localhost:3000/user/signup' => json => {
    signUpName      => 'test script user',
    signUpEmail     => 'mojotest@user.com',
    signUpPassword  => 'tester;6'
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(5 == $jsonBody->{error},                     $testname . 'Response JSON result is 5');
######### END INVALID CHARACTER IN PASSWORD TEST #########

######### START DELETE USER TEST #########
# this test deletes the valid user
my $testname = 'Delete valid user: ';
$tx = $ua->delete('http://localhost:3000/user/' . $validUserID);
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                       $testname . 'Response Code is 200');
ok($validUserID == $jsonBody->{id},             $testname . 'Response JSON ID exists');
ok('test script' eq $jsonBody->{first_name},    $testname . "Response JSON first name is 'test script'");
ok('user' eq $jsonBody->{last_name},            $testname . "Response JSON last name is 'user'");
ok(exists $jsonBody->{created_at},              $testname . 'Response JSON created date exists');
ok('ENG' eq $jsonBody->{lang},                  $testname . "Response JSON language is ENG");
ok(0 == $jsonBody->{active},                    $testname . 'Response JSON active is 0');
ok('EST' eq $jsonBody->{time_zone},             $testname . "Response JSON time zone is EST");
ok(exists $jsonBody->{password},                $testname . 'Response JSON password exists');
ok('NULL' eq $jsonBody->{profile_image_path},   $testname . "Response JSON profile image path is NULL");
ok($validUserEmail eq $jsonBody->{email},       $testname . "Response JSON email is 'mojotest\@user.com'");
#ok(5 == $jsonBody->{error},                     $testname . 'Response JSON result is 5');
######### END DELETE USER TEST #########


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
