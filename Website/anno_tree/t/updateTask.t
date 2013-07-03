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

######### START MINIMUM VALID TASK CREATION TEST #########
# this test creates a new task with only the minimum JSON name/value pairs
$testname = 'Valid minimum task creation: ';
my $validTaskDesc = 'Test Suite Task';
my $validTaskStatus = '1';
$tx = $uaValid->post($taskCreationURL => json => {
    treeid          => $validTreeID,
    description     => $validTaskDesc,
    status          => $validTaskStatus
});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                           $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                          $testname . 'Response JSON ID exists');
ok($validTaskDesc eq $jsonBody->{description},      $testname . "Response JSON description matches");
ok($validTaskStatus eq $jsonBody->{status},         $testname . "Response JSON status matches");
ok(exists $jsonBody->{leaf_id},                     $testname . "Response JSON leaf_id exists");
ok($validTreeID == $jsonBody->{tree_id},            $testname . "Response JSON tree_id matches");
ok(exists $jsonBody->{assigned_to},                 $testname . "Response JSON assigned_to exists");
ok(exists $jsonBody->{due_date},                    $testname . 'Response JSON due_date exists');
ok(exists $jsonBody->{created_at},                  $testname . 'Response JSON created_at exists');
ok($validUserID == $jsonBody->{created_by},         $testname . 'Response JSON created_by matches');
my $validTaskID = $jsonBody->{id};
######### END MINIMUM VALID TASK CREATION TEST #########

######### START VALID TASK UPDATE TEST #########
# this test updates an existing task
$testname = 'Valid task update: ';
my $validTaskUpdateURL = $server . $port . '/tasks/' . $validTaskID;
my $validDueDate = '2013-04-16 14:22';
$tx = $uaValid->put($validTaskUpdateURL => json => {
    description     => $validTaskDesc,
    status          => $validTaskStatus,
    leafid          => $validLeafID,
    assignedTo      => '',
    dueDate         => $validDueDate
});
$jsonBody = $json->decode($tx->res->body);

ok(204 == $tx->res->code,               $testname . 'Response Code is 204');
######### END VALID TASK UPDATE TEST #########

######### START VALID TASK UPDATE DUPLICATE TEST #########
# this test updates an existing task
$testname = 'Valid task update (duplicate): ';
$tx = $uaValid->put($validTaskUpdateURL => json => {
    description     => $validTaskDesc,
    status          => $validTaskStatus,
    leafid          => $validLeafID,
    assignedTo      => '',
    dueDate         => $validDueDate
});
$jsonBody = $json->decode($tx->res->body);

ok(204 == $tx->res->code,               $testname . 'Response Code is 204');
######### END VALID TASK UPDATE DUPLICATE TEST #########

######### START VALID TASK REQUIRED UPDATE TEST #########
# this test updates an existing task
$testname = 'Valid task required update: ';
$tx = $uaValid->put($validTaskUpdateURL => json => {
    description     => $validTaskDesc,
    status          => $validTaskStatus,
    leafid          => '',
    assignedTo      => '',
    dueDate         => ''
});
$jsonBody = $json->decode($tx->res->body);

ok(204 == $tx->res->code,               $testname . 'Response Code is 204');
######### END VALID TASK REQUIRED UPDATE TEST #########

######### START MISSING PARAMETERS TASK UPDATE TEST #########
# this test updates an existing task
$testname = 'Missing parameters task update: ';
$tx = $uaValid->put($validTaskUpdateURL => json => {
    description     => $validTaskDesc,
    status          => $validTaskStatus,
    leafid          => '',
    assignedTo      => '',
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(0 == $jsonBody->{error},             $testname . "Response JSON error result is 0");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
######### END MISSING PARAMETERS TASK UPDATE TEST #########

######### START INVALID DESCRIPTION TASK UPDATE TEST #########
# this test updates an existing task
$testname = 'Invalid task description update: ';
$tx = $uaValid->put($validTaskUpdateURL => json => {
    description     => ';',
    status          =>$validTaskStatus,
    leafid          => '',
    assignedTo      => '',
    dueDate         => ''
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(1 == $jsonBody->{error},             $testname . "Response JSON error result is 1");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
######### END INVALID DESCRIPTION TASK UPDATE TEST #########

######### START INVALID STATUS TASK UPDATE TEST #########
# this test updates an existing task
$testname = 'Invalid task status update: ';
$tx = $uaValid->put($validTaskUpdateURL => json => {
    description     => $validTaskDesc,
    status          => '200',
    leafid          => '',
    assignedTo      => '',
    dueDate         => ''
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(4 == $jsonBody->{error},             $testname . "Response JSON error result is 4");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
######### END INVALID STATUS TASK UPDATE TEST #########

######### START INVALID TASK UPDATE TEST #########
# this test attempts to update task that does not exist
$testname = 'Invalid task update: ';
my $invalidTaskUpdateURL = $server . $port . '/tasks/0';
$tx = $uaValid->put($invalidTaskUpdateURL => json => {
    description     => $validTaskDesc,
    status          => $validTaskStatus,
    leafid          => $validLeafID,
    assignedTo      => '',
    dueDate         => ''
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(2 == $jsonBody->{error},             $testname . "Response JSON error result is 2");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
######### END INVALID TASK UPDATE TEST #########

######### START INVALID ASSIGNED TASK UPDATE TEST #########
# this test attempts to update task assignment to a status that does not exist
$testname = 'Invalid task creation: ';
$tx = $uaValid->put($validTaskUpdateURL => json => {
    description     => $validTaskDesc,
    status          => $validTaskStatus,
    leafid          => $validLeafID,
    assignedTo      => '20',
    dueDate         => ''
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(5 == $jsonBody->{error},             $testname . "Response JSON error result is 5");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
######### END INVALID ASSIGNED TASK UPDATE TEST #########

######### START INVALID LEAF TASK UPDATE TEST #########
# this test attempts to update task assignment to a leaf that does not exist
$testname = 'Invalid leaf task update: ';
$tx = $uaValid->put($validTaskUpdateURL => json => {
    description     => $validTaskDesc,
    status          => $validTaskStatus,
    leafid          => '100',
    assignedTo      => '',
    dueDate         => ''
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,               $testname . 'Response Code is 406');
ok(6 == $jsonBody->{error},             $testname . "Response JSON error result is 6");
ok(exists $jsonBody->{txt},             $testname . 'Response JSON error text exists');
######### END INVALID LEAF TASK UPDATE TEST #########

######### START UNAUTHENTICATED USER TASK UPDATE TEST #########
# this test attempts to update a task with an unauthenticated user
$testname = 'Unauthenticated user task update: ';
my $uaUnauth = Mojo::UserAgent->new;
$tx = $uaUnauth->post($taskCreationURL => json => {
    treeid          => $validTreeID,
    description     => $validTaskDesc,
    status          => $validTaskStatus,
    assignedTo      => '',
    dueDate         => ''

});
$jsonBody = $json->decode($tx->res->body);

ok(401 == $tx->res->code,                   $testname . 'Response Code is 401');
ok(0 == $jsonBody->{error},                 $testname . "Response JSON error result is 0");
ok(exists $jsonBody->{txt},                 $testname . 'Response JSON error text exists');
######### END UNAUTHENTICATED USER TASK UPDATE TEST #########

done_testing();
