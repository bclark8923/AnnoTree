use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('AnnoTree');

# Test that the signup form exists
$t->get_ok('/user/signup')
    ->status_is(200)
    ->element_exists('form input[name="signUpName"]')
    ->element_exists('form input[name="signUpEmail"]')
    ->element_exists('form input[name="signUpPassword"]')
    ->element_exists('form input[type="submit"]');

# Test that a valid signup submission works
$t->post_ok('/user/signup' => form => {signUpName => 'Mojo Test', signUpEmail => 'test@mojo.com', signUpPassword => 'password'})
    ->status_is(200)
    ->json_is({result => '0'});

# Test that if an user is already signed up that they are not signed up again
$t->post_ok('/user/signup' => form => {signUpName => 'Mojo Test', signUpEmail => 'test@mojo.com', signUpPassword => 'password'})
    ->status_is(200)
    ->json_is({result => '2'});

# Test that an invalid email will not be accepted
$t->post_ok('/user/signup' => form => {signUpName => 'Mojo Test', signUpEmail => 'c', signUpPassword => 'password'})
    ->status_is(200)
    ->json_is({result => '1'});

# Test that a login form exists
$t->get_ok('/user/login')
    ->status_is(200)
    ->element_exists('form input[name="loginEmail"]')
    ->element_exists('form input[name="loginPassword"]')
    ->element_exists('form input[type="submit"]');

# Test a invalid email for logging in
$t->post_ok('/user/login' => form => {loginEmail => 'invalid@test.com', loginPassword => 'password'})
    ->status_is(200)
    ->json_is({userid => '-1'});

# Test a valid email but invalid password for logging in
$t->post_ok('/user/login' => form => {loginEmail => 'test@mojo.com', loginPassword => 'invalidpassword'})
    ->status_is(200)
    ->json_is({userid => '0'});

# Test a valid email and valid password for logging in
$t->post_ok('/user/login' => form => {loginEmail => 'test@mojo.com', loginPassword => 'password'})
    ->status_is(200)
    ->json_has({email => 'test@mojo.com'}); # this is not working correctly - need to identify that this specific element exists
 
done_testing();
