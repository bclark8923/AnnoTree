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
my $uaValid = Mojo::UserAgent->new; # use to make the authenticated user requests
my $uaIOS = Mojo::UserAgent->new; # use to make the iOS requests
my $json = Mojo::JSON->new; # use to help turn the response JSON into a Perl hash
my $tx; # this shuld be the Mojo::Transaction element return from the UA transaction
my $jsonBody; # this should be the body of the returned message if JSON
my $taskCreationURL = $server . $port . '/tasks';

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
my $validUserID = $jsonBody->{id};
######### END VALID USER SIGNUP/LOGIN TEST #########

######### START VALID FOREST CREATION TEST #########
# this test creates a new forest
$testname = 'Valid forest creation: ';
my $validForestName = 'Test Suite Forest';
my $validForestDesc = 'This is a forest created by the automated Mojolicious test suite';
my $forestURL = $server . $port . '/forest';
$tx = $uaValid->post($forestURL => json => {
    name            => $validForestName,
    description     => $validForestDesc
});
$jsonBody = $json->decode($tx->res->body);
 
ok(200 == $tx->res->code,                           $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                          $testname . 'Response JSON ID exists');
ok($validForestName eq $jsonBody->{name},           $testname . "Response JSON name matches");
ok($validForestDesc eq $jsonBody->{description},    $testname . "Response JSON description matches");
ok(exists $jsonBody->{created_at},                  $testname . 'Response JSON created_at exists');
my $validForestID = $jsonBody->{id};
######### END VALID FOREST CREATION TEST #########

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
ok(exists $jsonBody->{created_at},                  $testname . 'Response JSON created_at exists');
my $validTreeID = $jsonBody->{id};
######### END VALID TREE CREATION TEST #########

######### START VALID TREE UPDATE TEST #########
# this test updates an existing tree
$testname = 'Valid tree update: ';
my $validTreeUpdateURL = $server . $port . '/tree/' . $validTreeID;
$validTreeDesc = 'Tree description has been updated';
$validTreeName = 'Test Tree Updated';
$tx = $uaValid->put($validTreeUpdateURL => json => {
    description     => $validTreeDesc,
    name            => $validTreeName
});
$jsonBody = $json->decode($tx->res->body);

ok(204 == $tx->res->code,               $testname . 'Response Code is 204');
######### END VALID TREE UPDATE TEST #########

######### START VALID TREE UPDATE DUPLICATE TEST #########
# this test updates an existing tree
$testname = 'Valid tree update (duplicate): ';
$tx = $uaValid->put($validTreeUpdateURL => json => {
    description     => $validTreeDesc,
    name            => $validTreeName
});
$jsonBody = $json->decode($tx->res->body);

ok(204 == $tx->res->code,               $testname . 'Response Code is 204');
######### END VALID TREE UPDATE DUPLICATE TEST #########

######### START INVALID TREE UPDATE TEST #########
# this test attempts to update a tree that does not exist
$testname = 'Invalid tree update: ';
my $invalidTreeUpdateURL = $server . $port . '/tree/0';
$tx = $uaValid->put($invalidTreeUpdateURL => json => {
    description     => $validTreeDesc,
    name            => $validTreeName
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(2 == $jsonBody->{error},             $testname . "Response JSON error result is 2");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
######### END INVALID TREE UPDATE TEST #########

######### START MISSING PARAMETERS TREE UPDATE TEST #########
# this test attempts to update a tree with missing JSON name/value pairs
$testname = 'Missing parameters tree update: ';
$tx = $uaValid->put($validTreeUpdateURL => json => {
    description     => $validTreeDesc
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(0 == $jsonBody->{error},             $testname . "Response JSON error result is 0");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
######### END MISSING PARAMETERS TREE UPDATE TEST #########

######### START INVALID NAME TREE UPDATE TEST #########
# this test attempts to update a tree with missing JSON name/value pairs
$testname = 'Invalid name tree update: ';
$tx = $uaValid->put($validTreeUpdateURL => json => {
    description     => $validTreeDesc,
    name            => ';'
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(1 == $jsonBody->{error},             $testname . "Response JSON error result is 1");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
######### END INVALID NAME TREE UPDATE TEST #########

done_testing();
