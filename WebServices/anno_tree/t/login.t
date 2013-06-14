use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('AnnoTree');

# First submit a valid user
$t->post_ok('/user/signup' => form => {signUpName => 'Test Login', signUpEmail => 'login@test.com', signUpPassword => 'password'})
    ->status_is(200)
    ->json_is({result => 0});

# Test that a login form exists
$t->get_ok('/user/login')
    ->status_is(200)
    ->element_exists('form input[name="email"]')
    ->element_exists('form input[name="password"]')
    ->element_exists('form input[type="submit"]');

# Test a invalid login
$t->post_ok('/user/login' => form => {email => 'invalid@test.com', password => 'password'})
    ->status_is(200)
    ->json_is({userid => '-1'});

done_testing();
