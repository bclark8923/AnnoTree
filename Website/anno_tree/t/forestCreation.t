use Test::More;
#use Test::Mojo;
use Mojo::UserAgent;
use Data::Dumper;
use Mojo::JSON;

#my $t = Test::Mojo->new('AnnoTree');
my $uaValid = Mojo::UserAgent->new; # use to make the JSON POST requests
my $json = Mojo::JSON->new; # use to help turn the response JSON into a Perl hash
my $tx; # this shuld be the Mojo::Transaction element return from the UA transaction
my $jsonBody; # this should be the body of the returned message if JSON
my $forestCreationURL = 'http://localhost:3000/forest';

######### START VALID USER SIGNUP/LOGIN TEST #########
# this test creates a new valid user
my $testname = 'Valid user signup: ';
my $validUserEmail = 'mojotest@user.com';
my $validUserPass = 'tester1';
$tx = $uaValid->post('http://localhost:3000/user/signup' => json => {
    signUpName      => 'test suite user',
    signUpEmail     => $validUserEmail,
    signUpPassword  => $validUserPass
});
$jsonBody = $json->decode($tx->res->body);

# if the user already exists then log them in
if ($tx->res->code == 406 && $jsonBody->{error} == 2) {
    $testname = 'Valid user login: ';
    $tx = $uaValid->post('http://localhost:3000/user/login' => json => {
        loginEmail     => $validUserEmail,
        loginPassword  => $validUserPass
    });
    $jsonBody = $json->decode($tx->res->body);
}

ok(200 == $tx->res->code,                               $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                              $testname . 'Response JSON ID exists');
ok('test suite' eq $jsonBody->{first_name},             $testname . "Response JSON first name is 'test suite'");
ok('user' eq $jsonBody->{last_name},                    $testname . "Response JSON last name is 'user'");
ok(exists $jsonBody->{created_at},                      $testname . 'Response JSON created date exists');
ok('ENG' eq $jsonBody->{lang},                          $testname . "Response JSON language is ENG");
ok(1 == $jsonBody->{active},                            $testname . 'Response JSON active is 1');
ok('EST' eq $jsonBody->{time_zone},                     $testname . "Response JSON time zone is EST");
ok('img/user.png' eq $jsonBody->{profile_image_path},   $testname . "Response JSON profile image path is img/user.png");
ok($validUserEmail eq $jsonBody->{email},               $testname . "Response JSON email is '" . $validUserEmail . "'");
######### END VALID USER SIGNUP/LOGIN TEST #########

######### START VALID FOREST CREATION TEST #########
# this test creates a new forest
my $testname = 'Valid forest creation: ';
my $validForestName = 'Test Suite Forest';
my $validForestDesc = 'This is a forest created by the automated Mojolicious test suite';
$tx = $uaValid->post($forestCreationURL => json => {
    name            => $validForestName,
    description     => $validForestDesc
});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                           $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                          $testname . 'Response JSON ID exists');
ok($validForestName eq $jsonBody->{name},           $testname . "Response JSON name matches");
ok($validForestDesc eq $jsonBody->{description},    $testname . "Response JSON description matches");
ok(exists $jsonBody->{created_at},                  $testname . 'Response JSON create_at exists');
######### END VALID FOREST CREATION TEST #########

######### START INVALID FOREST NAME CREATION TEST #########
# this test attempts to create a forest without a name
my $testname = 'Invalid forest name creation: ';
$tx = $uaValid->post($forestCreationURL => json => {
    name            => '',
    description     => $validForestDesc
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                   $testname . 'Response Code is 406');
ok(2 == $jsonBody->{error},                 $testname . "Response JSON error is 2");
ok(exists $jsonBody->{txt},                 $testname . 'Response JSON error text exists');
######### END INVALID FOREST NAME CREATION TEST #########

######### START MISSING REQUEST JSON VALUES TEST #########
# this test creates a forest with missing JSON values in the request
my $testname = 'Missing request parameters forest creation: ';
$tx = $uaValid->post($forestCreationURL => json => {
    name            => $validForestName
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                   $testname . 'Response Code is 406');
ok(0 == $jsonBody->{error},                 $testname . "Response JSON error is 0");
ok(exists $jsonBody->{txt},                 $testname . 'Response JSON error text exists');
######### END MISSING REQUEST JSON VALUES TEST #########

######### START UNAUTHENTICATED USER FOREST CREATION TEST #########
# this test attempts to create a forest with an unauthenticated user
my $testname = 'Unauthenticated user forest creation: ';
my $uaUnauth = Mojo::UserAgent->new;
$tx = $uaUnauth->post($forestCreationURL => json => {
    name            => $validForestName,
    description     => $validForestDesc
});
$jsonBody = $json->decode($tx->res->body);

ok(401 == $tx->res->code,                   $testname . 'Response Code is 401');
ok(0 == $jsonBody->{error},                 $testname . "Response JSON error result is 0");
ok(exists $jsonBody->{txt},                 $testname . 'Response JSON error text exists');
######### END UNAUTHENTICATED USER FOREST CREATION TEST #########

done_testing();
