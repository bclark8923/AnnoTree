package AnnoTree;
use Mojo::Base 'Mojolicious';

use AnnoTree::Model::MySQL;
use Crypt::SaltedHash;
use Data::Dumper;

# file upload size limit - 5MB
$ENV{MOJO_MAX_MESSAGE_SIZE} = 5242880;


# This method will run once at server start
sub startup {
    my $self = shift;
    
    # secret passphrase for sessions
    $self->secret('protect the ANN0T33$ before THEY g3t T@k3n');
    
    # set what mode we should be operating in
    $self->mode('development');

    # load the plugins
    $self->plugin('DebugHelper');
=begin oldmysqlcon
    $self->plugin('MySQL', {
        db => {
            database    => 'annotree',
            host        => 'localhost',
            port        => '3306',
            username    => 'annotree',
            password    => 'ann0tr33s',
        }
    });
=end oldmysqlcon
=cut
    AnnoTree::Model::MySQL->init({
        database    => 'annotree',
        host        => 'localhost',
        port        => '3306',
        username    => 'annotree',
        password    => 'ann0tr33s',
    });

    $self->plugin('authentication', {
        autoload_user => 1,
        load_user => sub {
            my ($self, $userid) = @_;
            my $sessionObj = {
                userid => $userid
            };
            return $sessionObj;
        },
        validate_user => sub {
            my ($self, $email, $pw) = @_;
            my $result = AnnoTree::Model::MySQL->db->execute(
                'call validate_user(:email)',
                {
                    email => $email
                }
            );
            while (my $return = $result->fetch) {
                my $shash = $return->[1];
                my $valid = Crypt::SaltedHash->validate($shash, $pw);
                return undef unless $valid;
                return $return->[0];
            }
            return undef;
        }
    });
    # Documentation browser under "/perldoc"
    #$self->plugin('PODRenderer');
    
    # Routes
    my $r = $self->routes;
    # Bridge for services that required an authenticated user
    my $authr = $r->bridge->to('controller-auth#check');
    
    # ===== STATIC FILES =====
    $r->get('/')                ->to('controller-static#splash');
    $r->get('/login')           ->to('controller-static#login');
    $authr->get('/testauth')    ->to('controller-static#testAuth');

    # ===== USERS =====
    $r->post('/user/signup')                                ->to('controller-auth#signup'); # invites need to be added to existing forest, new users have sample forest, etc. created automatically
    $r->post('/user/login')                                 ->to('controller-auth#login');
    $authr->post('/user/logout')                            ->to('controller-auth#logoutUser');
    $authr->delete('/user/:userid' => [userid => qr/\d+/])  ->to('controller-user#deleteUser'); # not working

    # ===== TASKS =====
    $authr->post('/tasks')                                  ->to('controller-task#create');
    $authr->get('/:treeid/tasks' => [treeid => qr/\d+/])    ->to('controller-task#treeTaskInfo');
    
    # ===== FORESTS =====
    $authr->post('/forest') ->to('controller-forest#create');
    $authr->get('/forest')  ->to('controller-forest#forestInfo');

    # ===== TREES =====
    $authr->post('/:forestid/tree' => [forestid => qr/\d+/])    ->to('controller-tree#create');
    $authr->get('/tree/:treeid' => [treeid => qr/\d+/])         ->to('controller-tree#treeInfo');
    $authr->put('/tree/:treeid/user' => [treeid => qr/\d+/])    ->to('controller-tree#addUserToTree');
 
    # ===== BRANCHES =====
    $authr->post('/:treeid/branch' => [treeid => qr/\d+/])->to('controller-branch#create');

    # ===== LEAVES =====
    $authr->post('/:branchid/leaf' => [branchid => qr/\d+/])    ->to('controller-leaf#create');
    $authr->get('/leaf/:leafid' => [leafid => qr/\d+/])         ->to('controller-leaf#leafInfo');
    $r->post('/ios/leaf' => [leafid => qr/\d+/]) ->to('controller-leaf#iosUpload');
    $r->get('/ios/leaf' => [leafid => qr/\d+/]) ->to('controller-leaf#iosTestUpload');

    # ===== ANNOTATIONS =====
    $authr->post('/:leafid/annotation' => [leafid => qr/\d+/])          ->to('controller-annotation#create');

}

return 1;
