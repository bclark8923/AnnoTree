package AnnoTree;
use Mojo::Base 'Mojolicious';

use AnnoTree::Model::MySQL;
use Crypt::SaltedHash;
use Data::Dumper;
use Config::General;

# file upload size limit - 10MB
$ENV{MOJO_MAX_MESSAGE_SIZE} = 10485760;

# This method will run once at server start
sub startup {
    my $self = shift;
    
    my $conf = Config::General->new('/opt/config.txt');
    my %config = $conf->getall;
 
    # secret passphrase for sessions
    $self->secret('protect the ANN0T33$ before THEY g3t T@k3n');
    
    # set what mode we should be operating in - TODO: add modes
    $self->mode('development');
    
    # sessions expire after a day
    $self->sessions->default_expiration(86400);
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
            
            my $return = $result->fetch;
            return undef if (!$return);
            my $shash = $return->[1];
            my $valid = Crypt::SaltedHash->validate($shash, $pw);
            return undef unless $valid;
            return $return->[0];
            return undef;
        }
    });
    
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
    $r->post('/user/login/trees')                           ->to('controller-user#loginTrees');
    $authr->post('/user/logout')                            ->to('controller-auth#logoutUser');
    $authr->get('/user/knownpeople')                        ->to('controller-user#knownPeople');
    $authr->get('/user')                                    ->to('controller-user#getUserInformation');
    $authr->post('/user/feedback')                          ->to('controller-user#feedback');
    #$authr->delete('/user/:userid' => [userid => qr/\d+/])  ->to('controller-user#deleteUser');
    
    # ===== COMMENTS =====
    $authr->post('/comments/leaf/:leafid' => [leafid => qr/\d+/])   ->to('controller-comments#leafCreate');
    $authr->get('/comments/leaf/:leafid' => [leafid => qr/\d+/])    ->to('controller-comments#leafInfo');
    
    # ===== FORESTS =====
    $authr->post('/forest')                                         ->to('controller-forest#create');
    $authr->get('/forest')                                          ->to('controller-forest#forestInfo');
    $authr->get('/forest/:forestid/users' => [forestid => qr/\d+/]) ->to('controller-forest#forestUsers');
    $authr->put('/forest/:forestid' => [forestid => qr/\d+/])       ->to('controller-forest#update');
    $authr->put('/forest/:forestid/owner' => [forestid => qr/\d+/]) ->to('controller-forest#updateOwner');
    $authr->delete('/forest/:forestid' => [forestid => qr/\d+/])    ->to('controller-forest#deleteForest');

    # ===== TREES =====
    $authr->post('/:forestid/tree' => [forestid => qr/\d+/])                                ->to('controller-tree#create');
    $authr->get('/tree/:treeid' => [treeid => qr/\d+/])                                     ->to('controller-tree#treeInfo');
    $authr->get('/tree/:treeid/users' => [treeid => qr/\d+/])                               ->to('controller-tree#treeUsers');
    $authr->put('/tree/:treeid' => [treeid => qr/\d+/])                                     ->to('controller-tree#rename');
    $authr->delete('/tree/:treeid' => [treeid => qr/\d+/])                                  ->to('controller-tree#deleteTree');
    $authr->put('/tree/:treeid/user' => [treeid => qr/\d+/])                                ->to('controller-tree#addUserToTree');
    $authr->delete('/tree/:treeid/user/:userid' => [treeid => qr/\d+/, userid => qr/\d+/])  ->to('controller-tree#removeUserFromTree');
    $r->get('/ios/tokens')  ->to('controller-tree#iosTokens');
 
    # ===== BRANCHES =====
    $authr->post('/:treeid/branch' => [treeid => qr/\d+/])                                      ->to('controller-branch#create');
    $authr->get('/:treeid/branch/:branchid' => [treeid => qr/\d+/, branchid => qr/\d+/])        ->to('controller-branch#info');
    $authr->put('/:treeid/branch/:branchid' => [treeid => qr/\d+/, branchid => qr/\d+/])        ->to('controller-branch#rename');
    $authr->delete('/:treeid/branch/:branchid' => [treeid => qr/\d+/, branchid => qr/\d+/])     ->to('controller-branch#delete');
    $authr->get('/:treeid/parentbranch/:branchid' => [treeid => qr/\d+/, branchid => qr/\d+/])  ->to('controller-branch#parentInfo');

    # ===== LEAVES =====
    $authr->post('/:branchid/leaf' => [branchid => qr/\d+/])                                                            ->to('controller-leaf#create');
    $authr->get('/leaf/:leafid' => [leafid => qr/\d+/])                                                                 ->to('controller-leaf#leafInfo');
    $authr->put('/leaf/:leafid' => [leafid => qr/\d+/])                                                                 ->to('controller-leaf#rename');
    $authr->put('/leaf/:leafid/assign' => [leafid => qr/\d+/])                                                          ->to('controller-leaf#assign');
    $authr->delete('/leaf/:leafid/assign/:remove' => [leafid => qr/\d+/, remove => qr/\d+/])                            ->to('controller-leaf#assignRemove');
    $authr->put('/:treeid/:branchid/leaf/:leafid' => [treeid => qr/\d+/, branchid => qr/\d+/, leafid => qr/\d+/])       ->to('controller-leaf#changeBranch');
    $authr->put('/:treeid/:branchid/subchange/:leafid' => [treeid => qr/\d+/, branchid => qr/\d+/, leafid => qr/\d+/])  ->to('controller-leaf#changeSubBranch');
    $authr->delete('/leaf/:leafid' => [leafid => qr/\d+/])                                                              ->to('controller-leaf#deleteLeaf');
    $r->post('/ios/leaf')       ->to('controller-leaf#iosUpload');
    $r->post('/chrome/leaf')    ->to('controller-leaf#chromeUpload');
    $r->get('/ios/leaf')        ->to('controller-leaf#iosTestUpload');

    # ===== ANNOTATIONS =====
    $authr->post('/:leafid/annotation' => [leafid => qr/\d+/])  ->to('controller-annotation#create');
    $authr->get('/annotation/:annoid' => [annoid => qr/\d+/])   ->to('controller-annotation#getImage'); 
}

return 1;
