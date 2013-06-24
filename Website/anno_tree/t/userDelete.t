use Test::More;
use Test::Mojo;
use Mojo::UserAgent;
use Data::Dumper;
use Mojo::JSON;
=begin notfunc
my $json = Mojo::JSON->new; # use to help turn the response JSON into a Perl hash
my $tx; # this shuld be the Mojo::Transaction element return from the UA transaction
my $jsonBody; # this should be the body of the returned message if JSON

######### START DELETE USER TEST #########
# this test deletes the valid user
my $testname = 'Delete valid user: ';
$tx = $ua->delete('http://localhost:3000/user/' . $validUserID);
$jsonBody = $json->decode($tx->res->body);

ok(200 == $tx->res->code,                       $testname . 'Response Code is 200');
ok($validUserID == $jsonBody->{id},             $testname . 'Response JSON ID exists');
ok('test script' eq $jsonBody->{first_name},    $testname . "Response JSON first name is 'test script'");
ok('user' eq $jsonBody->{last_name},            $testname . "Response JSON last name is 'user'");
ok(exists $jsonBody->{created_at},              $testname . 'Response JSON created date exists');
ok('ENG' eq $jsonBody->{lang},                  $testname . "Response JSON language is ENG");
ok(0 == $jsonBody->{active},                    $testname . 'Response JSON active is 0');
ok('EST' eq $jsonBody->{time_zone},             $testname . "Response JSON time zone is EST");
ok(exists $jsonBody->{password},                $testname . 'Response JSON password exists');
ok('NULL' eq $jsonBody->{profile_image_path},   $testname . "Response JSON profile image path is NULL");
ok($validUserEmail eq $jsonBody->{email},       $testname . "Response JSON email is 'mojotest\@user.com'");
#ok(5 == $jsonBody->{error},                     $testname . 'Response JSON result is 5');
######### END DELETE USER TEST #########

######### START DELETE INVALID USER TEST #########
# this test attempts to delete a user that does not exist
my $testname = 'Delete invalid user: ';
$tx = $ua->delete('http://localhost:3000/user/0');
$jsonBody = $json->decode($tx->res->body);

ok(404 == $tx->res->code,                       $testname . 'Response Code is 404');
ok(1 == $jsonBody->{error},                     $testname . 'Response JSON error is 1');
######### START DELETE INVALID USER TEST #########

=end notfunc
=cut
done_testing();
