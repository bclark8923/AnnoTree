use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('AnnoTree');
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

