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
    ->json_is({result => 2});

# Test that an invalid email will not be accepted
$t->post_ok('/user/signup' => form => {signUpName => 'Mojo Test', signUpEmail => 'c', signUpPassword => 'password'})
    ->status_is(200)
    ->json_is({result => 1});

done_testing();
