package AnnoTree::Model::User;

use Mojo::Base -strict;
use Crypt::SaltedHash;
#use EV;
#use DBIx::Custom;

#use strict;
#use warnings;
=begin comment
my $dbi = DBIx::Custom->connect(
    dsn         => 'dbi:mysql:database=annotree;host=localhost;port=3306',
    user        => 'annotree',
    password    => 'ann0tr33s'
);
=end comment
=cut
sub createSaltedHash {
    my $password = shift;
    
    #creating the salted hash
    my $crypt = Crypt::SaltedHash->new(algorithm=>'SHA-512');
    $crypt->add($password);
    my $shash = $crypt->generate();
    return $shash;
}

# inserts a new user into the DB
sub signup {
    my ($self, $params) = @_;
    
    $self->debug($self->dumper($params));
    my $pass = createSaltedHash($params->{'password'});
    $self->debug($pass);
    my $result = $self->db_dbi->execute( #$dbi->execute(
        "select create_user(:password, :firstName, :lastName, :email, :lang, :timezone, :profileImage)",
        {
            email           => $params->{'email'}, 
            password        => '' . $pass,
            firstName       => $params->{'firstName'},
            lastName        => $params->{'lastName'},
            lang            => 'ENG',
            timezone        => 'EST',
            profileImage    => 'NULL'
        }
    );
=begin comment
    my $result = $dbi->insert({
            email       => $params->{'email'}, 
            password    => $params->{'password'},
            first_name  => $params->{'firstName'},
            last_name  => $params->{'lastName'}
        },
        table => 'user');
=end comment
=cut

    #$self->debug($result->fetch->[0]);
    my $json = {}; 
    $json->{'result'} = $result->fetch->[0];
    return $json;
}

return 1;
