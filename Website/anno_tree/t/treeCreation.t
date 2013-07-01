use Test::More;
#use Test::Mojo;
use Mojo::UserAgent;
use Data::Dumper;
use Mojo::JSON;
use AppConfig;

# grab the inforamtion from the configuration file
my $config = AppConfig->new();
$config->define('server=s');
$config->define('port=s');
$config->define('screenshot=s');
$config->define('annotationpath=s');
$config->define('devRoot=s');
$config->file('/opt/config.txt');
my $server = $config->get('server');
my $port = ':' . $config->get('port');
my $fileToUpload = $config->get('screenshot');

#my $t = Test::Mojo->new('AnnoTree');
my $uaValid = Mojo::UserAgent->new; # use to make the JSON POST requests
my $json = Mojo::JSON->new; # use to help turn the response JSON into a Perl hash
my $tx; # this shuld be the Mojo::Transaction element return from the UA transaction
my $jsonBody; # this should be the body of the returned message if JSON
my $forestCreationURL = $server . $port . '/forest';

######### START VALID USER SIGNUP/LOGIN TEST #########
# this test creates a new valid user
my $testname = 'Valid user signup: ';
my $validUserEmail = 'mojotest@user.com';
my $validUserPass = 'tester1';
$tx = $uaValid->post($server . $port . '/user/signup' => json => {
    signUpName      => 'test suite user',
    signUpEmail     => $validUserEmail,
    signUpPassword  => $validUserPass
});
$jsonBody = $json->decode($tx->res->body);

# if the user already exists then log them in
if ($tx->res->code == 406 && $jsonBody->{error} == 2) {
    $testname = 'Valid user login: ';
    $tx = $uaValid->post($server . $port . '/user/login' => json => {
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
ok(3 == $jsonBody->{status},                            $testname . 'Response JSON status is 3');
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
my $validForestID = $jsonBody->{id};
######### END VALID FOREST CREATION TEST ##########

######### START VALID TREE CREATION TEST #########
# this test creates a new tree
$testname = 'Valid tree creation: ';
my $treeCreationURL = $server . $port . '/' . $validForestID . '/tree';
my $validTreeName = 'Test Suite Tree';
my $validTreeDesc = 'This is a tree created by the automated Mojolicious test suite';
$tx = $uaValid->post($treeCreationURL => json => {
    name            => $validTreeName,
    description     => $validTreeDesc
});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                           $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                          $testname . 'Response JSON ID exists');
ok($validForestID == $jsonBody->{forest_id},        $testname . "Response JSON forest_id matches");
ok($validTreeName eq $jsonBody->{name},             $testname . "Response JSON name matches");
ok($validTreeDesc eq $jsonBody->{description},      $testname . "Response JSON description matches");
ok(exists $jsonBody->{token},                       $testname . "Response JSON token exists");
ok('img/logo.png' eq $jsonBody->{logo},             $testname . "Response JSON logo matches");
ok(exists $jsonBody->{created_at},                  $testname . 'Response JSON create_at exists');
######### END VALID TREE CREATION TEST #########

######### START INVALID TREE NAME CREATION TEST #########
# this test attempts to create a tree without including one alphanumeric character
$testname = 'Invalid tree name creation: ';
$tx = $uaValid->post($treeCreationURL => json => {
    name            => '',
    description     => $validTreeDesc
});
$jsonBody = $json->decode($tx->res->body);
ok(406 == $tx->res->code,                   $testname . 'Response Code is 406');
ok(4 == $jsonBody->{error},                 $testname . "Response JSON error is 4");
ok(exists $jsonBody->{txt},                 $testname . 'Response JSON error text exists');
######### START INVALID TREE NAME CREATION TEST #########

######### START MISSING REQUEST JSON VALUES TEST #########
# this test attempts to create a tree without including all the JSON request name/value pairs
$testname = 'Missing request parameters for tree creation: ';
$tx = $uaValid->post($treeCreationURL => json => {
    name            => $validTreeName
});
$jsonBody = $json->decode($tx->res->body);
ok(406 == $tx->res->code,                   $testname . 'Response Code is 406');
ok(0 == $jsonBody->{error},                 $testname . "Response JSON error is 0");
ok(exists $jsonBody->{txt},                 $testname . 'Response JSON error text exists');
######### END MISSING REQUEST JSON VALUES TEST #########

######### START MISSING FOREST TREE CREATION TEST #########
# this test attempts to create a tree on a forest that does not exist
$testname = 'Missing forest tree creation: ';
my $missingForestID = 0;
my $treeMissingURL = $server . $port . '/' . $missingForestID . '/tree';
$tx = $uaValid->post($treeMissingURL => json => {
    name            => $validTreeName,
    description     => $validTreeDesc
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                   $testname . 'Response Code is 406');
ok(2 == $jsonBody->{error},                 $testname . "Response JSON error is 2");
ok(exists $jsonBody->{txt},                 $testname . 'Response JSON error text exists');
######### END MISSING FOREST TREE CREATION TEST #########

######### START FORBIDDEN TREE CREATION TEST #########
# this test attempts to create a tree on a forest the user does not have access to
$testname = 'Forbidden tree creation: ';
my $forbiddenForestID = 1;
my $treeForbiddenURL = $server . $port . '/' . $forbiddenForestID . '/tree';
$tx = $uaValid->post($treeForbiddenURL => json => {
    name            => $validTreeName,
    description     => $validTreeDesc
});
$jsonBody = $json->decode($tx->res->body);

ok(403 == $tx->res->code,                   $testname . 'Response Code is 403');
ok(3 == $jsonBody->{error},                 $testname . "Response JSON error is 3");
ok(exists $jsonBody->{txt},                 $testname . 'Response JSON error text exists');
######### END FORBIDDEN TREE CREATION TEST #########

######### START UNAUTHENTICATED USER TREE CREATION TEST #########
# this test attempts to create a forest with an unauthenticated user
$testname = 'Unauthenticated user tree creation: ';
my $uaUnauth = Mojo::UserAgent->new;
#$treeCreationURL = 'http://localhost:3000/' . $validForestID . '/tree';
$tx = $uaUnauth->post($forestCreationURL => json => {
    name            => $validForestName,
    description     => $validForestDesc
});
$jsonBody = $json->decode($tx->res->body);

ok(401 == $tx->res->code,                   $testname . 'Response Code is 401');
ok(0 == $jsonBody->{error},                 $testname . "Response JSON error result is 0");
ok(exists $jsonBody->{txt},                 $testname . 'Response JSON error text exists');
######### END UNAUTHENTICATED USER TREE CREATION TEST #########

done_testing();
