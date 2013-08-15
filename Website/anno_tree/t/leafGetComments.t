use Test::More;
#use Test::Mojo;
use Mojo::UserAgent;
use Data::Dumper;
use Mojo::JSON;
use Config::General;

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;

#my $server = $config{server}->{base_url};
my $server = localhost;
my $port = ':' . $config{server}->{'port'} . '/services';
#my $port = '/services';

#my $t = Test::Mojo->new('AnnoTree');
my $uaValid = Mojo::UserAgent->new; # use to make the JSON POST requests
my $json = Mojo::JSON->new; # use to help turn the response JSON into a Perl hash
my $tx; # this shuld be the Mojo::Transaction element return from the UA transaction
my $jsonBody; # this should be the body of the returned message if JSON

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

######### START NO LEAF COMMENTS RETRIEVAL TEST #########
# this test asks for comments on a leaf that has none
$testname = 'No leaf comments existing retrieval: ';
my $commentURL = $server . $port . '/comments/leaf/' . $validLeafID;
$tx = $uaValid->get($commentURL);

ok(204 == $tx->res->code,       $testname . 'Response Code is 204');
######### END NO LEAF COMMENTS RETRIEVAL TEST #########

######### START VALID COMMENT CREATION TEST #########
# this test creates a new comment
$testname = 'Valid comment creation: ';
my $validComment = 'This would be a valid comment bro on leaf ' . $validLeafID;
$tx = $uaValid->post($commentURL => json => {
    comment => $validComment,
});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                   $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                  $testname . 'Response JSON ID exists');
ok($validUserID == $jsonBody->{user_id},    $testname . "Response JSON user_id matches");
ok($validLeafID == $jsonBody->{leaf_id},    $testname . "Response JSON leaf_id matches");
ok($validComment eq $jsonBody->{comment},   $testname . "Response JSON comment matches");
ok(exists $jsonBody->{created_at},          $testname . 'Response JSON created_at exists');
ok(exists $jsonBody->{updated_at},          $testname . 'Response JSON updated_at exists');
######### END VALID COMMENT CREATION TEST #########

######### START VALID COMMENT 2 CREATION TEST #########
# this test creates a new comment
$testname = 'Valid comment creation 2: ';
$validComment = 'This would be a valid comment 2222222 bro on leaf ' . $validLeafID;
$tx = $uaValid->post($commentURL => json => {
    comment => $validComment,
});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                   $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                  $testname . 'Response JSON ID exists');
ok($validUserID == $jsonBody->{user_id},    $testname . "Response JSON user_id matches");
ok($validLeafID == $jsonBody->{leaf_id},    $testname . "Response JSON leaf_id matches");
ok($validComment eq $jsonBody->{comment},   $testname . "Response JSON comment matches");
ok(exists $jsonBody->{created_at},          $testname . 'Response JSON created_at exists');
ok(exists $jsonBody->{updated_at},          $testname . 'Response JSON updated_at exists');
######### END VALID COMMENT 2 CREATION TEST #########

######### START VALID LEAF COMMENTS RETRIEVAL TEST #########
# this test retrieves comments from a leaf
$testname = 'Valid leaf comments retrieval: ';
$tx = $uaValid->get($commentURL);
$jsonBody = $json->decode($tx->res->body);
print Dumper($jsonBody);
ok(200 == $tx->res->code,           $testname . 'Response Code is 200');
ok(exists $jsonBody->{comments},    $testname . 'Reponse JSON has comments');
######### END VALID LEAF COMMENTS RETRIEVAL TEST #########

######### START INVALID LEAF COMMENTS RETRIEVAL TEST #########
# this test attempts to retrieve comments from a leaf it does not have access to
$testname = 'Invalid leaf comments retrieval: ';
my $invalidCommentURL = $server . $port . '/comments/leaf/1';
$tx = $uaValid->get($invalidCommentURL);
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,       $testname . 'Response Code is 406');
ok(1 == $jsonBody->{error},     $testname . 'Response JSON error is 1');
ok(exists $jsonBody->{txt},     $testname . 'Response JSON error text exists');
######### END INVALID LEAF COMMENTS RETRIEVAL TEST #########


done_testing;
