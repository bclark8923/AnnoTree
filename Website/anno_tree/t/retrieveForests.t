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
my $server = 'http://localhost';
my $port = ':3000';
my $forestURL = $server . $port . '/forest';

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

ok(200 == $tx->res->code,                       $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                      $testname . 'Response JSON ID exists');
ok('test suite' eq $jsonBody->{first_name},     $testname . "Response JSON first name is 'test suite'");
ok('user' eq $jsonBody->{last_name},            $testname . "Response JSON last name is 'user'");
ok(exists $jsonBody->{created_at},              $testname . 'Response JSON created date exists');
ok('ENG' eq $jsonBody->{lang},                  $testname . "Response JSON language is ENG");
ok(1 == $jsonBody->{active},                    $testname . 'Response JSON active is 1');
ok('EST' eq $jsonBody->{time_zone},             $testname . "Response JSON time zone is EST");
ok('img/user.png' eq $jsonBody->{profile_image_path},   $testname . "Response JSON profile image path is img/user.png");
ok($validUserEmail eq $jsonBody->{email}, $testname . "Response JSON email is '" . $validUserEmail . "'");
######### END VALID USER SIGNUP/LOGIN TEST #########

=begin forcre
######### START VALID FOREST CREATION TEST #########
# this test creates a new forest
$testname = 'Valid forest creation: ';
my $validForestName = 'Test Suite Forest';
my $validForestDesc = 'This is a forest created by the automated Mojolicious test suite';
$tx = $uaValid->post($forestURL => json => {
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
=end forcre
=cut
######### START VALID FOREST RETRIEVAL TEST #########
# this test creates a new forest
$testname = 'Valid forest creation: ';
$tx = $uaValid->get($forestURL);
$jsonBody = $json->decode($tx->res->body);
print Dumper($jsonBody);
ok(200 == $tx->res->code,                           $testname . 'Response Code is 200');
#ok(exists $jsonBody->{id},                          $testname . 'Response JSON ID exists');
#ok($validForestName eq $jsonBody->{name},           $testname . "Response JSON name matches");
#ok($validForestDesc eq $jsonBody->{description},    $testname . "Response JSON description matches");
#ok(exists $jsonBody->{created_at},                  $testname . 'Response JSON create_at exists');
######### END VALID FOREST RETRIEVAL TEST #########

done_testing();
