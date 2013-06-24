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
            #$self->debug("user email is $email and pw is $pw");
            my $result = AnnoTree::Model::MySQL->db->execute(
                'call validate_user(:email)',
                {
                    email => $email
                }
            );
            #print Dumper($self);
            while (my $return = $result->fetch) {
                my $shash = $return->[1];
                #print "users shash is $shash"; 
                my $valid = Crypt::SaltedHash->validate($shash, $pw);
                #$self->debug("valid is $valid");
                return undef unless $valid;
                return $return->[0];
            }
            #$self->debug('user does not exist');
            return undef;
        }
    });
    # Documentation browser under "/perldoc"
    #$self->plugin('PODRenderer');
    
    

    # Router
    my $r = $self->routes;
    # Bridge for services that required an authenticated user
    my $authr = $r->bridge->to('controller-auth#check');

    # ===== USERS =====
    $r->post('/user/signup')                                ->to('controller-auth#signup'); # working - need to create trees, etc. when not a referral - referrals need to be added to forest/tree?, also need to figure out how to activate users
    $r->post('/user/login')                                 ->to('controller-auth#login'); # working - should it return the list of forests the user has access to?
    $authr->post('/user/logout')                            ->to('controller-auth#logoutUser');
    $authr->delete('/user/:userid' => [userid => qr/\d+/])  ->to('controller-user#deleteUser'); # working

    # ===== FORESTS =====
    $authr->post('/:userid/forest')->to('controller-forest#create');
    $authr->get('/forest')->to('controller-forest#forestsForUser'); # done

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
