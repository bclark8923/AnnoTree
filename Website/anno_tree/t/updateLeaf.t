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
my $validBranchID = $jsonBody->{id};
######### END VALID BRANCH CREATION TEST #########

######### START VALID LEAF CREATION TEST #########
# this test creates a new leaf
$testname = 'Valid leaf creation: ';
my $leafCreationURL = $server . $port . '/' . $validBranchID . '/leaf';
my $validLeafName = 'Test Suite Leaf';
my $validLeafDesc = 'This is a leaf created by the automated Mojolicious test suite';
$tx = $uaValid->post($leafCreationURL => json => {
    name            => $validLeafName,
    description     => $validLeafDesc
});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                           $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                          $testname . 'Response JSON ID exists');
ok($validUserID == $jsonBody->{owner_user_id},      $testname . "Response JSON owner_user_id matches");
ok($validBranchID == $jsonBody->{branch_id},        $testname . "Response JSON branch_id matches");
ok($validLeafName eq $jsonBody->{name},             $testname . "Response JSON name matches");
ok($validLeafDesc eq $jsonBody->{description},      $testname . "Response JSON description matches");
ok(exists $jsonBody->{created_at},                  $testname . 'Response JSON created_at exists');
my $validLeafID = $jsonBody->{id};
######### END VALID LEAF CREATION TEST #########

######### START VALID LEAF UPDATE TEST #########
# this test updates an existing leaf
$testname = 'Valid leaf update: ';
my $validLeafUpdateURL = $server . $port . '/leaf/' . $validLeafID;
$validLeafDesc = 'Leaf description has been updated';
$validLeafName = 'Test Leaf Updated';
$tx = $uaValid->put($validLeafUpdateURL => json => {
    description     => $validLeafDesc,
    name            => $validLeafName,
    branchid        => $validBranchID
});
$jsonBody = $json->decode($tx->res->body);

ok(204 == $tx->res->code,               $testname . 'Response Code is 204');
######### END VALID LEAF UPDATE TEST #########

######### START VALID LEAF UPDATE DUPLICATE TEST #########
# this test updates an existing leaf (duplicate update)
$testname = 'Valid leaf update (duplicate): ';
$tx = $uaValid->put($validLeafUpdateURL => json => {
    description     => $validLeafDesc,
    name            => $validLeafName,
    branchid        => $validBranchID
});
$jsonBody = $json->decode($tx->res->body);

ok(204 == $tx->res->code,               $testname . 'Response Code is 204');
######### END VALID LEAF UPDATE DUPLICATE TEST #########

######### START MISSING PARAMETERS LEAF UPDATE TEST #########
# this test attempts to update a leaf but is missing a required JSON name/value pair
$testname = 'Missing parameters leaf update: ';
$tx = $uaValid->put($validLeafUpdateURL => json => {
    description     => $validLeafDesc,
    name            => $validLeafName
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(0 == $jsonBody->{error},             $testname . "Response JSON error result is 0");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
######### END MISSING PARAMETERS LEAF UPDATE TEST #########

######### START INVALID NAME LEAF UPDATE TEST #########
# this test attempts to update a leaf with an invalid branchid
$testname = 'Invalid branch leaf update: ';
$tx = $uaValid->put($validLeafUpdateURL => json => {
    description     => $validLeafDesc,
    name            => ';',
    branchid        => $validBranchID
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(5 == $jsonBody->{error},             $testname . "Response JSON error result is 5");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
######### END INVALID NAME LEAF UPDATE TEST #########

######### START INVALID BRANCH LEAF UPDATE TEST #########
# this test attempts to update a leaf with an invalid branchid
$testname = 'Invalid branch leaf update: ';
$tx = $uaValid->put($validLeafUpdateURL => json => {
    description     => $validLeafDesc,
    name            => $validLeafName,
    branchid        => ''
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(4 == $jsonBody->{error},             $testname . "Response JSON error result is 4");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
######### END INVALID BRANCH LEAF UPDATE TEST #########

######### START INVALID LEAF LEAF UPDATE TEST #########
# this test attempts to update an invalid leaf
$testname = 'Invalid leaf leaf update: ';
my $invalidLeafUpdateURL = $server . $port . '/leaf/0';
$tx = $uaValid->put($invalidLeafUpdateURL => json => {
    description     => $validLeafDesc,
    name            => $validLeafName,
    branchid        => $validBranchID
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(2 == $jsonBody->{error},             $testname . "Response JSON error result is 2");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
######### END INVALID LEAF LEAF UPDATE TEST #########

done_testing();
