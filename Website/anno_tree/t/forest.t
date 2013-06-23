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

######### START VALID USER SIGNUP/LOGIN TEST #########
# this test creates a new valid user
my $testname = 'Valid user signup: ';
$tx = $ua->post('http://localhost:3000/user/signup' => json => {
    signUpName      => 'forest test user',
    signUpEmail     => 'mojotest@forest.com',
    signUpPassword  => 'tester1'
});
$jsonBody = $json->decode($tx->res->body);

# if the user already exists then log them in
if ($tx->res->code == 406 && $jsonBody->{error} == 2) {
    $testname = 'Valid user login: ';
    $tx = $ua->post('http://localhost:3000/user/login' => json => {
        loginEmail     => 'mojotest@forest.com',
        loginPassword  => 'tester1'
    });
    $jsonBody = $json->decode($tx->res->body);
}

ok(200 == $tx->res->code,                       $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                      $testname . 'Response JSON ID exists');
ok('forest test' eq $jsonBody->{first_name},    $testname . "Response JSON first name is 'forest test'");
ok('user' eq $jsonBody->{last_name},            $testname . "Response JSON last name is 'user'");
ok(exists $jsonBody->{created_at},              $testname . 'Response JSON created date exists');
ok('ENG' eq $jsonBody->{lang},                  $testname . "Response JSON language is ENG");
ok(1 == $jsonBody->{active},                    $testname . 'Response JSON active is 1');
ok('EST' eq $jsonBody->{time_zone},             $testname . "Response JSON time zone is EST");
ok(exists $jsonBody->{password},                $testname . 'Response JSON password exists');
ok('NULL' eq $jsonBody->{profile_image_path},   $testname . "Response JSON profile image path is NULL");
ok('mojotest@forest.com' eq $jsonBody->{email}, $testname . "Response JSON email is 'mojotest\@forest.com'");

my $forestUserID = $jsonBody->{id};
######### END VALID USER SIGNUP/LOGIN TEST #########

######### START VALID FOREST CREATION TEST #########
# this test creates a new valid user
my $testname = 'Valid forest creation: ';
my $forestCreationURL = 'http://localhost:3000/' . $forestUserID . '/forest';
my $validForestName = 'Test Suite Forest';
my $validForestDesc = 'This is a forest created by the automated Mojolicious test suite';
$tx = $ua->post($forestCreationURL => json => {
    name            => $validForestName,
    description     => $validForestDesc
});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                           $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                          $testname . 'Response JSON ID exists');
ok($validForestName eq $jsonBody->{name},           $testname . "Response JSON name matches");
ok($validForestDesc eq $jsonBody->{description},    $testname . "Response JSON description matches");
my $validForestID = $jsonBody->{id};
######### END VALID FOREST CREATION TEST #########

######### START MISSING REQUEST JSON VALUES TEST #########
# this test creates a forest with missing JSON values in the request
my $testname = 'Missing request parameters forest creation: ';
$tx = $ua->post($forestCreationURL => json => {
    name            => $validForestName
});
$jsonBody = $json->decode($tx->res->body);

ok(406 == $tx->res->code,                       $testname . 'Response Code is 406');
ok(6 == $jsonBody->{error},                     $testname . "Response JSON error result is 6");
######### END MISSING REQUEST JSON VALUES TEST #########

######### START INVALID USER FOREST CREATION TEST #########
# this test attempts to create a forest with a non-existing user
my $testname = 'Missing request parameters forest creation: ';
$tx = $ua->post('http://localhost:3000/0/forest' => json => {
    name            => $validForestName,
    description     => $validForestDesc
});
$jsonBody = $json->decode($tx->res->body);

ok(404 == $tx->res->code,                       $testname . 'Response Code is 404');
ok(1 == $jsonBody->{error},                     $testname . "Response JSON error result is 1");
######### END INVALID USER FOREST CREATION TEST #########

######### START VALID USER FOREST GET TEST #########
# this test grabs the existing forests for an user
my $testname = 'Valid user forest retrieval: ';
my $getForestURL = 'http://localhost:3000/' . $forestUserID .'/forest'; 
$tx = $ua->get($getForestURL);
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                       $testname . 'Response Code is 200');
ok(exists $jsonBody->{forests},                 $testname . "Response JSON forests element exists");

# have to iterate through the JSON to find the forest
my $foundForest;
foreach $element (@{$jsonBody->{forests}}) {
    next unless $element->{id} == $validForestID;
    $foundForest = $element;
}

ok($validForestID == $foundForest->{id},            $testname . "GET /:userid/forest Response JSON matches created forest id");
ok($validForestName eq $foundForest->{name},        $testname . "GET /:userid/forest Response JSON matches created forest name");
ok($validForestDesc eq $foundForest->{description}, $testname . "GET /:userid/forest Response JSON matches created forest description");
######### END VALID USER FOREST GET TEST #########

=begin oldtests
# Test that the forest creation form exists
$t->get_ok('/forest/create')
    ->status_is(200)
    ->element_exists('form input[name="userid"]')
    ->element_exists('form input[name="name"]')
    ->element_exists('form textarea[name="description"]')
    ->element_exists('form input[type="submit"]');

# Test that a valid signup submission works
$t->post_ok('/forest' => form => {userid => '2', name => 'test forest', description => 'forest create using the mojo test suite bro'})
    ->status_is(200)
    ->json_is({result => '0'});
=end oldtests
=cut
done_testing();

