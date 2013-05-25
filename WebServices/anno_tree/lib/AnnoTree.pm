package AnnoTree;
use Mojo::Base 'Mojolicious';

# file upload size limit - 5MB
$ENV{MOJO_MAX_MESSAGE_SIZE} = 5242880;

# This method will run once at server start
sub startup {
    my $self = shift;

    # Documentation browser under "/perldoc"
    #$self->plugin('PODRenderer');

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to('example#welcome');
    
    # ===== FORESTS =====
    $r->get('/forest')->to('forest#list');
    $r->get('/forest/:id' => [id => qr/\d+/])->to('forest#unique');

    # ===== TREES =====
    $r->get('/:forestid/tree' => [forestid => qr/\d+/])->to('tree#list');

    # ===== BRANCHES =====
    $r->get('/:forestid/:treeid/branch' => [forestid => qr/\d+/, treeid => qr/\d+/])->to('branch#list');

    # ===== Leaves =====
    $r->get('/:forestid/:treeid/:branchid/leaf' => [forestid => qr/\d+/, treeid => qr/\d+/, branchid => qr/\d+/])->to('leaves-leaf#list');
    $r->get('/:forestid/:treeid/:branchid/leaf/testupload' => [forestid => qr/\d+/, treeid => qr/\d+/, branchid => qr/\d+/])->to('leaves-leaf#testImageUpload');
    $r->post('/:forestid/:treeid/:branchid/leaf' => [forestid => qr/\d+/, treeid => qr/\d+/, branchid => qr/\d+/])->to('leaves-leaf#imagePost');
}

return 1;
