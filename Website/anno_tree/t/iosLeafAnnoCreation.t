use Test::More;
#use Test::Mojo;
use Mojo::UserAgent;
use Data::Dumper;
use Mojo::JSON;
use Config::General;

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;

my $server = $config{server}->{base_url};
my $port = ':' . $config{server}->{'port'};
my $fileToUpload = $config{server}->{'screenshot'};

#my $t = Test::Mojo->new('AnnoTree');
my $uaValid = Mojo::UserAgent->new; # use to make the authenticated user requests
my $uaIOS = Mojo::UserAgent->new; # use to make the iOS requests
my $json = Mojo::JSON->new; # use to help turn the response JSON into a Perl hash
my $tx; # this shuld be the Mojo::Transaction element return from the UA transaction
my $jsonBody; # this should be the body of the returned message if JSON
my $iosCreationURL = $server . $port . '/ios/leaf';

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
my $validForestCreated = $jsonBody->{created_at};
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
my $validTreeToken = $jsonBody->{token};
######### END VALID TREE CREATION TEST #########

######### START VALID BRANCH CREATION TEST #########
# this test creates a new branch
$testname = 'Valid branch creation: ';
my $branchCreationURL = $server . $port . '/' . $validTreeID . '/branch';
my $validBranchName = 'Test Suite Branch';
my $validBranchDesc = 'This is a branch created by the automated Mojolicious test suite';
$tx = $uaValid->post($branchCreationURL => json => {
    name            => $validBranchName,
    description     => $validBranchDesc
});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                           $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                          $testname . 'Response JSON ID exists');
ok($validTreeID == $jsonBody->{tree_id},            $testname . "Response JSON tree_id matches");
ok($validBranchName eq $jsonBody->{name},           $testname . "Response JSON name matches");
ok($validBranchDesc eq $jsonBody->{description},    $testname . "Response JSON description matches");
ok(exists $jsonBody->{created_at},                  $testname . 'Response JSON created_at exists');
######### END VALID BRANCH CREATION TEST #########

########## START VALID IOS LEAF CREATION TEST #########
# this test creates a new leaf and a new annotation from an iOS request
$testname = 'Valid iOS leaf creation: ';
$tx = $uaIOS->post($iosCreationURL => form => {annotation => {file => $fileToUpload, 'Content-Type' => 'image/png'}, token => $validTreeToken, leafName => 'Test iOS Leaf Creation'});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                       $testname . 'Response Code is 200');
ok(exists $jsonBody->{result},                  $testname . 'Response JSON result exists');
######### END VALID IOS LEAF CREATION TEST #########

########## START MISSING REQUEST TOKEN IOS LEAF CREATION TEST #########
# this test attempts to create an iOS leaf with missing request parameters
$testname = 'Missing request token iOS leaf creation: ';
$tx = $uaIOS->post($iosCreationURL => form => {annotation => {file => $fileToUpload, 'Content-Type' => 'image/png'}});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(0 == $jsonBody->{error},             $testname . "Response JSON error result is 0");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
########## END MISSING REQUEST TOKEN IOS LEAF CREATION TEST #########

######### START MISSING REQUEST ANNOTATION IOS LEAF CREATION TEST #########
# this test attempts to create an iOS leaf with missing request parameters
$testname = 'Missing request annotation iOS leaf creation: ';
$tx = $uaIOS->post($iosCreationURL => form => {token => $validTreeToken});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(0 == $jsonBody->{error},             $testname . "Response JSON error result is 0");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
########## END MISSING REQUEST ANNOTATION IOS LEAF CREATION TEST #########

########## START ILL FORMED TOKEN IOS LEAF CREATION TEST #########
# this test attempts to create an iOS leaf with an ill formed token
$testname = 'Ill formed token iOS leaf creation: ';
$tx = $uaIOS->post($iosCreationURL => form => {annotation => {file => $fileToUpload, 'Content-Type' => 'image/png'}, token => substr($validTreeToken, 0, 63)});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(0 == $jsonBody->{error},             $testname . "Response JSON error result is 0");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
########## END ILL FORMED TOKEN IOS LEAF CREATION TEST #########

########## START BAD PARAMETER NAME IOS LEAF CREATION TEST #########
# this test attempts to create an iOS leaf with a bad parameter name
$testname = 'Bad parameter name iOS leaf creation: ';
$tx = $uaIOS->post($iosCreationURL => form => {annotations => {file => $fileToUpload, 'Content-Type' => 'image/png'}, token => $validTreeToken});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(0 == $jsonBody->{error},             $testname . "Response JSON error result is 0");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
########## END BAD PARAMETER NAME IOS LEAF CREATION TEST #########

done_testing();
