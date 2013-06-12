package AnnoTree;
use Mojo::Base 'Mojolicious';

# file upload size limit - 5MB
$ENV{MOJO_MAX_MESSAGE_SIZE} = 5242880;


# This method will run once at server start
sub startup {
    my $self = shift;
    
    # secret passphrase for sessions
    $self->secret('protect the ANN0T33$ before THEY g3t T@k3n');
    
    # load the plugins
    $self->plugin('DebugHelper');
    # Documentation browser under "/perldoc"
    #$self->plugin('PODRenderer');

    # Router
    my $r = $self->routes;

    # ===== FORESTS =====
    $r->get('/forest')->to('controller-forest#list');
    $r->get('/forest/:id' => [id => qr/\d+/])->to('controller-forest#unique');
    $r->get('/forest/create')->to('controller-forest#testCreate');
    $r->post('/forest')->to('controller-forest#create');

    # ===== TREES =====
    $r->get('/:forestid/tree' => [forestid => qr/\d+/])->to('controller-tree#list');

    # ===== BRANCHES =====
    $r->get('/:forestid/:treeid/branch' => [forestid => qr/\d+/, treeid => qr/\d+/])->to('branch#list');

    # ===== Leaves =====
    $r->get('/:forestid/:treeid/:branchid/leaf' => [forestid => qr/\d+/, treeid => qr/\d+/, branchid => qr/\d+/])->to('leaves-leaf#list');

    # ===== Annotations =====
    $r->get('/:forestid/:treeid/:branchid/:leafid/annotation' => [forestid => qr/\d+/, treeid => qr/\d+/, branchid => qr/\d+/, leafid => qr/\d+/])->to('leaves-annotation#list');
    $r->get('/:forestid/:treeid/:branchid/:leafid/annotation/testupload' => [forestid => qr/\d+/, treeid => qr/\d+/, branchid => qr/\d+/, leafid => qr/\d+/])->to('leaves-annotation#testScreenshotUpload');
    $r->post('/:forestid/:treeid/:branchid/:leafid/annotation' => [forestid => qr/\d+/, treeid => qr/\d+/, branchid => qr/\d+/, leafid => qr/\d+/])->to('leaves-annotation#annotationCreation');
    $r->get('/:forestid/:treeid/:branchid/:leafid/annotation/display' => [forestid => qr/\d+/, treeid => qr/\d+/, branchid => qr/\d+/, leafid => qr/\d+/])->to('leaves-annotation#annotationDisplay');


}

return 1;
