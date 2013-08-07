package AnnoTree;
use Mojo::Base 'Mojolicious';

use AnnoTree::Model::MySQL;
use Crypt::SaltedHash;
use Data::Dumper;
use Config::General;

# file upload size limit - 5MB
$ENV{MOJO_MAX_MESSAGE_SIZE} = 10485760;

# This method will run once at server start
sub startup {
    my $self = shift;
    
    # Get the configuration settings
    my $conf = Config::General->new('/opt/config.txt');
    my %config = $conf->getall;
 
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
    # print Dumper(\%config);
    # print $config{database}->{server} . "\n";
    # print $config{database}->{port} . "\n";
    AnnoTree::Model::MySQL->init({
        database    => 'annotree',
        host        => $config{database}->{server},
        port        => $config{database}->{port},
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
            AnnoTree::Model::MySQL->db->execute(
                'call update_login(:userid)',
                {
                    userid => $userid
                }
            ); 
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
    my $r = $self->routes->bridge('/services');
    # Bridge for services that required an authenticated user
    my $authr = $r->bridge->to('controller-auth#check');
    
    # ===== USERS =====
    $r->post('/user/signup')                                ->to('controller-auth#signup');
    $r->post('/user/login')                                 ->to('controller-auth#login');
    $r->post('/user/beta')                                  ->to('controller-user#beta');
    $r->post('/user/reset')                                 ->to('controller-user#setReset');
    $r->post('/user/reset/:token')                          ->to('controller-user#reset');
    $authr->post('/user/logout')                            ->to('controller-auth#logoutUser');
    $authr->get('/user/knownpeople')                        ->to('controller-user#knownPeople');
    $authr->get('/user')                                    ->to('controller-user#getUserInformation');
    $authr->post('/user/feedback')                          ->to('controller-user#feedback');
    #$authr->delete('/user/:userid' => [userid => qr/\d+/])  ->to('controller-user#deleteUser');

    # ===== TASKS ===== deprecated for now
    #$authr->post('/tasks')                                  ->to('controller-task#create');
    #$authr->get('/:treeid/tasks' => [treeid => qr/\d+/])    ->to('controller-task#treeTaskInfo');
    #$authr->put('/tasks/:taskid' => [taskid => qr/\d+/])    ->to('controller-task#updateTask');
    #$authr->delete('/tasks/:taskid' => [taskid => qr/\d+/]) ->to('controller-task#deleteTask');
    
    # ===== COMMENTS =====
    $authr->post('/comments/leaf/:leafid' => [leafid => qr/\d+/])   ->to('controller-comments#leafCreate');
    $authr->get('/comments/leaf/:leafid' => [leafid => qr/\d+/])    ->to('controller-comments#leafInfo');
    
    # ===== FORESTS =====
    $authr->post('/forest')                                         ->to('controller-forest#create');
    $authr->get('/forest')                                          ->to('controller-forest#forestInfo');
    $authr->put('/forest/:forestid' => [forestid => qr/\d+/])       ->to('controller-forest#update');
    $authr->delete('/forest/:forestid' => [forestid => qr/\d+/])    ->to('controller-forest#deleteForest');

    # ===== TREES =====
    $authr->post('/:forestid/tree' => [forestid => qr/\d+/])    ->to('controller-tree#create');
    $authr->get('/tree/:treeid' => [treeid => qr/\d+/])         ->to('controller-tree#treeInfo');
    $authr->put('/tree/:treeid' => [treeid => qr/\d+/])         ->to('controller-tree#update');
    $authr->delete('/tree/:treeid' => [treeid => qr/\d+/])      ->to('controller-tree#deleteTree');
    $authr->put('/tree/:treeid/user' => [treeid => qr/\d+/])    ->to('controller-tree#addUserToTree');
    $authr->delete('/tree/:treeid/user/:userid' => [treeid => qr/\d+/, userid => qr/\d+/])    ->to('controller-tree#removeUserFromTree');
    $r->get('/ios/tokens')  ->to('controller-tree#iosTokens');
 
    # ===== BRANCHES =====
    $authr->post('/:treeid/branch' => [treeid => qr/\d+/])->to('controller-branch#create');

    # ===== LEAVES =====
    $authr->post('/:branchid/leaf' => [branchid => qr/\d+/])    ->to('controller-leaf#create');
    $authr->get('/leaf/:leafid' => [leafid => qr/\d+/])         ->to('controller-leaf#leafInfo');
    $authr->put('/leaf/:leafid' => [leafid => qr/\d+/])         ->to('controller-leaf#update');
    $authr->delete('/leaf/:leafid' => [leafid => qr/\d+/])      ->to('controller-leaf#deleteLeaf');
    $r->post('/ios/leaf' => [leafid => qr/\d+/])    ->to('controller-leaf#iosUpload');
    $r->get('/ios/leaf' => [leafid => qr/\d+/])     ->to('controller-leaf#iosTestUpload');

    # ===== ANNOTATIONS =====
    $authr->post('/:leafid/annotation' => [leafid => qr/\d+/])->to('controller-annotation#create');
    $authr->get('/annotation/:annoid' => [annoid => qr/\d+/])->to('controller-annotation#getImage'); 

}

return 1;
