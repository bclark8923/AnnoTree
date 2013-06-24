use Test::More;
use Test::Mojo;
use Mojo::UserAgent;
use Data::Dumper;
use Mojo::JSON;

#my $t = Test::Mojo->new('AnnoTree');
#my $ua = Mojo::UserAgent->new; # use to make the JSON POST requests
my $json = Mojo::JSON->new; # use to help turn the response JSON into a Perl hash
my $tx; # this shuld be the Mojo::Transaction element return from the UA transaction
my $jsonBody; # this should be the body of the returned message if JSON

=begin testuser
$tx = $ua->post('http://localhost:3000/user/signup' => json => {
    signUpName      => 'matt a price',
    signUpEmail     => 'mattprice11@gmail.com',
    signUpPassword  => 'groovy11'
});
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                       $testname . 'Response Code is 200');
print Dumper($jsonBody);

my $testname = 'Valid forest creation: ';
my $forestCreationURL = 'http://localhost:3000/3/forest';
my $validForestName = 'Test Suite Forest';
my $validForestDesc = 'This is a forest created by the automated Mojolicious test suite';
$tx = $ua->post($forestCreationURL => json => {
    name            => $validForestName,
    description     => $validForestDesc
});
$jsonBody = $json->decode($tx->res->body);
print Dumper($jsonBody);

ok(200 == $tx->res->code,                           $testname . 'Response Code is 200');
ok(exists $jsonBody->{id},                          $testname . 'Response JSON ID exists');
ok($validForestName eq $jsonBody->{name},           $testname . "Response JSON name matches");
ok($validForestDesc eq $jsonBody->{description},    $testname . "Response JSON description matches");
=end testuser
=cut
$tx = $ua->post('http://localhost:3000/user/login' => json => {
    loginEmail     => 'mattprice11@gmail.com',
    loginPassword  => 'groovy11'
});
$jsonBody = $json->decode($tx->res->body);
print "valid user login\n";
print Dumper($jsonBody);
ok(200 == $tx->res->code,                       $testname . 'Response Code is 200');
$tx = $ua->get('http://localhost:3000/3/forest');
$jsonBody = $json->decode($tx->res->body);
print "get forests for valid user\n";
print Dumper($jsonBody);
print "logout valid user\n";
$tx = $ua->post('http://localhost:3000/user/logout');
$jsonBody = $json->decode($tx->res->body);
print 'logout user' ."\n";
print Dumper($jsonBody);
$tx = $ua->get('http://localhost:3000/3/forest');
$jsonBody = $json->decode($tx->res->body);
print "get forests for logged out user\n";
print Dumper($jsonBody);

my $ua2 = Mojo::UserAgent->new; # use to make the JSON POST requests
$tx = $ua2->post('http://localhost:3000/user/login' => json => {
    loginEmail     => 'mattprice11@gmail.com',
    loginPassword  => 'groovy'
});
$jsonBody = $json->decode($tx->res->body);
print "valid email invalid password login\n";
print Dumper($jsonBody);
ok(401 == $tx->res->code,                       $testname . 'Response Code is 401');

my $ua3 = Mojo::UserAgent->new; # use to make the JSON POST requests
$tx = $ua3->post('http://localhost:3000/user/login' => json => {
    loginEmail     => 'fakeuser@gmail.com',
    loginPassword  => 'groovy22'
});
$jsonBody = $json->decode($tx->res->body);
print "invalid email login\n";
print Dumper($jsonBody);
ok(401 == $tx->res->code,                       $testname . 'Response Code is 401');
$tx = $ua3->get('http://localhost:3000/3/forest');
$jsonBody = $json->decode($tx->res->body);
print "invalid user try to get valid users forests\n";
print Dumper($jsonBody);
ok(401 == $tx->res->code,                       $testname . 'Response Code is 401');
done_testing();
