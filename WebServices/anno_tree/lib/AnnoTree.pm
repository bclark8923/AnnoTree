package AnnoTree;
use Mojo::Base 'Mojolicious';

use AnnoTree::Model::MySQL;

# file upload size limit - 5MB
$ENV{MOJO_MAX_MESSAGE_SIZE} = 5242880;


# This method will run once at server start
sub startup {
    my $self = shift;
    
    # secret passphrase for sessions
    $self->secret('protect the ANN0T33$ before THEY g3t T@k3n');
    
    # load the plugins
    $self->plugin('DebugHelper');
    $self->plugin('MySQL', {
            db => {
                database    => 'annotree',
                host        => 'localhost',
                port        => '3306',
                username    => 'annotree',
                password    => 'ann0tr33s',
            }
        });
    # Documentation browser under "/perldoc"
    #$self->plugin('PODRenderer');
    
    AnnoTree::Model::MySQL->init({
        database    => 'annotree',
        host        => 'localhost',
        port        => '3306',
        username    => 'annotree',
        password    => 'ann0tr33s',
    });

    # Router
    my $r = $self->routes;

    # ===== USERS =====
    $r->post('/user/signup')                        ->to('controller-user#signup'); # working - need to create trees, etc. when not a referral - referrals need to be added to forest/tree?, also need to figure out how to activate users
    $r->post('/user/login')                         ->to('controller-user#login'); # working - should it return the list of forests the user has access to?
    $r->delete('/user/:userid' => [userid => qr/\d+/])    ->to('controller-user#deleteUser'); # working

    # ===== FORESTS =====
    $r->post('/:userid/forest' => [userid => qr/\d+/])->to('controller-forest#create');
    $r->get('/:userid/forest' => [userid => qr/\d+/])->to('controller-forest#forestsForUser'); # done

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
