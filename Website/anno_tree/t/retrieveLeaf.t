use Test::More;
#use Test::Mojo;use Mojo::UserAgent;
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
$config->file('/opt/config.txt');
my $server = $config->get('server');
my $port = ':' . $config->get('port');
my $fileToUpload = $config->get('screenshot');

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
my $validTreeCreated = $jsonBody->{created_at};
my $validTreeLogo = $jsonBody->{logo};
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
my $validBranchCreated = $jsonBody->{created_at};
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
my $validLeafCreated = $jsonBody->{created_at};
######### END VALID LEAF CREATION TEST #########

########## START VALID ANNOTATION CREATION TEST #########
# this test creates a new leaf
$testname = 'Valid annotation creation: ';
my $annoCreationURL = $server . $port . '/' . $validLeafID . '/annotation';
$tx = $uaValid->post($annoCreationURL => form => {uploadedFile => {file => $fileToUpload, 'Content-Type' => 'image/png'}});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                       $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                      $testname . 'Response JSON ID exists');
ok($validLeafID == $jsonBody->{leaf_id},        $testname . "Response JSON leaf_id matches");
ok('image/png' eq $jsonBody->{mime_type},       $testname . "Response JSON mime_type matches");
ok(exists $jsonBody->{path},                    $testname . "Response JSON name matches");
ok(exists $jsonBody->{filename},                $testname . "Response JSON description matches");
ok(exists $jsonBody->{created_at},              $testname . 'Response JSON created_at exists');
my $validAnnoID = $jsonBody->{id};
my $validAnnoMime = $jsonBody->{mime_type};
my $validAnnoPath = $jsonBody->{path};
my $validAnnoFilename = $jsonBody->{filename};
my $validAnnoCreated = $jsonBody->{created_at};
######### END VALID ANNOTATION CREATION TEST #########

######### START VALID LEAF RETRIEVAL TEST #########
# this test retrieves the information for a single leaf
$testname = 'Valid leaf retrieval: ';
my $leafGetURL = $server . $port . '/leaf/' . $validLeafID;
$tx = $uaValid->get($leafGetURL);
$jsonBody = $json->decode($tx->res->body);
my $testAnno;
foreach my $anno (@{$jsonBody->{annotations}}) {
    next unless $anno->{id} = $validAnnoID;
    $testAnno = $anno;
}

ok(200 == $tx->res->code,                               $testname . 'Response Code is 200');
ok($validLeafID == $jsonBody->{id},                     $testname . 'Response JSON leaf id matches');
ok($validLeafName == $jsonBody->{name},                 $testname . 'Response JSON leaf name matches');
ok($validLeafDesc == $jsonBody->{description},          $testname . 'Response JSON leaf description matches');
ok($validLeafCreated == $jsonBody->{created_at},        $testname . 'Response JSON leaf created matches');
ok($validUserID == $jsonBody->{owner_user_id},          $testname . 'Response JSON leaf owner_user_id matches');
ok($validBranchID == $jsonBody->{branch_id},            $testname . 'Response JSON leaf branch_id matches');
ok(exists $jsonBody->{annotations},                     $testname . 'Response JSON leaf annotations exists');
ok($validAnnoID == $testAnno->{id},                     $testname . 'Response JSON annotation id matches');
ok($validAnnoMime == $testAnno->{mime_type},            $testname . 'Response JSON annotation mime_type matches');
ok($validAnnoPath == $testAnno->{path},                 $testname . 'Response JSON annotation path matches');
ok($validAnnoFilename == $testAnno->{filename},         $testname . 'Response JSON annotation filename matches');
ok($validAnnoCreated == $testAnno->{created_at},        $testname . 'Response JSON annotation created_at matches');
ok($validLeafID == $testAnno->{leaf_id},                $testname . 'Response JSON annotation leaf_id matches');
######### END VALID LEAF RETRIEVAL TEST #########

######### START EXISTING LEAF NO PERMISSIONS RETRIEVAL TEST #########
# this test attempts to retrieve a tree that exists but the user does not have access to
$testname = 'Existing leaf no permissions retrieval: ';
my $invalidLeafGetURL = $server . $port . '/leaf/1';
$tx = $uaValid->get($invalidLeafGetURL);
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                   $testname . 'Response Code is 406');
ok(1 == $jsonBody->{error},                 $testname . "Response JSON error result is 1");
ok(exists $jsonBody->{txt},                 $testname . 'Response JSON error text exists');
######### END EXISTING LEAF NO PERMISSIONS RETRIEVAL TEST #########

######### START NONEXISTING LEAF RETRIEVAL TEST #########
# this test attempts to retrieve a tree that exists but the user does not have access to
$testname = 'Nonexisting leaf retrieval: ';
$invalidLeafGetURL = $server . $port . '/leaf/0';
$tx = $uaValid->get($invalidLeafGetURL);
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                   $testname . 'Response Code is 406');
ok(1 == $jsonBody->{error},                 $testname . "Response JSON error result is 1");
ok(exists $jsonBody->{txt},                 $testname . 'Response JSON error text exists');
######### END NONEXISTING LEAF RETRIEVAL TEST #########

######### START UNAUTHENTICATED USER LEAF RETRIEVAL TEST #########
# this test attempts to retrieve a leaf's information with an unauthenticated user
$testname = 'Unauthenticated user leaf retrieval: ';
my $uaUnauth = Mojo::UserAgent->new;
$tx = $uaUnauth->get($leafGetURL);
$jsonBody = $json->decode($tx->res->body);

ok(401 == $tx->res->code,                   $testname . 'Response Code is 401');
ok(0 == $jsonBody->{error},                 $testname . "Response JSON error result is 0");
ok(exists $jsonBody->{txt},                 $testname . 'Response JSON error text exists');
######### END UNAUTHENTICATED USER LEAF RETRIEVAL TEST #########

done_testing();
