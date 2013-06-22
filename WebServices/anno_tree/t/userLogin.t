use Test::More;
#use Test::Mojo;
use Mojo::UserAgent;
use Data::Dumper;
use Mojo::JSON;

#my $t = Test::Mojo->new('AnnoTree');
my $ua = Mojo::UserAgent->new; # use to make the JSON POST requests
my $json = Mojo::JSON->new; # use to help turn the response JSON into a Perl hash
my $tx; # this shuld be the Mojo::Transaction element return from the UA transaction
my $jsonBody; # this should be the body of the returned message if JSON

######### START VALID USER SIGNUP TEST #########
# this test creates a new valid user
my $testname = 'Valid user signup: ';
$tx = $ua->post('http://localhost:3000/user/signup' => json => {
    signUpName      => 'test script user',
    signUpEmail     => 'mojotest@login.com',
    signUpPassword  => 'tester1'
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
ok('mojotest@login.com' eq $jsonBody->{email},   $testname . "Response JSON email is 'mojotest\@user.com'");
######### END VALID USER SIGNUP TEST #########

######### START VALID USER LOGIN TEST #########
# this test logs on a valid user
my $testname = 'Valid user login: ';
$tx = $ua->post('http://localhost:3000/user/login' => json => {
    loginEmail     => 'mojotest@login.com',
    loginPassword  => 'tester1'
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
ok('mojotest@login.com' eq $jsonBody->{email},  $testname . "Response JSON email is 'mojotest\@login.com'");
######### END VALID USER TEST #########

######### START MISSING REQUEST JSON PARAMETERS TEST #########
# this test attempts to send missing JSON parameters
my $testname = 'Missing request parameters user login: ';
$tx = $ua->post('http://localhost:3000/user/signup' => json => {
    signUpEmail     => 'mojotest@login.com'
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(6 == $jsonBody->{error},                     $testname . 'Response JSON result is 6');
######### END MISSING REQUEST JSON PARAMETERS TEST #########

######### START INVALID PASSWORD TEST #########
# this test logs on a valid user
my $testname = 'Invalid password user login: ';
$tx = $ua->post('http://localhost:3000/user/login' => json => {
    loginEmail     => 'mojotest@login.com',
    loginPassword  => 'invalidpassword1'
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(0 == $jsonBody->{error},                     $testname . 'Response JSON result is 0');
######### END INVALID PASSWORD TEST #########

######### START INVALID EMAIL/USER TEST #########
# this test logs on a valid user
my $testname = 'Valid user/email login: ';
$tx = $ua->post('http://localhost:3000/user/login' => json => {
    loginEmail     => 'mojotest1234@login.com',
    loginPassword  => 'invalidpassword1'
});
$jsonBody = $json->decode($tx->res->body);

ok(404 == $tx->res->code,                       $testname . 'Response Code is 404');
ok(1 == $jsonBody->{error},                     $testname . 'Response JSON result is 1');
######### END INVALID EMAIL/USER TEST #########

done_testing();
