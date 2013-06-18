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

# validates a user attempting to log in
# returns 0 if invalid email
# returns -1 if password is incorrect
# returns the user's id otherwise (a positive int)
sub login {
    my ($self, $params) = @_;
    
    #$self->debug('before query');
=begin oldselect
    my $result = $self->db_dbi->execute(
        "select id, password from user where email=:email",
        {
            email => $params->{email}
        }
    );
=end oldselect
=cut
    my $result = $self->db_dbi->execute(
        "select get_user(:email)",
        {
            email => $params->{email}
        }
    );
    my $fetch = $result->fetch;
    my $json = {};
    
    if ($fetch->[0]) {
        my @fetch = split(/, /, $fetch->[0]);
        #$self->debug('userid: ' . $fetch[0]);
        $self->debug($self->dumper($fetch));
        my $shash = $fetch[1];
        my $valid = Crypt::SaltedHash->validate($shash, $params->{password});
        $self->debug("valid is $valid");
        
        if ($valid == 1) {
            $json->{userid} = '' . $fetch[0];
            $json->{firstName} = '' . $fetch[2];
            $json->{lastName} = '' . $fetch[3];
            $json->{email} = '' . $fetch[4];
            $json->{lang} = '' . $fetch[5];
            $json->{timezone} = '' . $fetch[6];
            $json->{profileImagePath} = '' . $fetch[7];
        } else { # password was invalid
            $json->{userid} = '0';
        }
    } else { # user does not exist
        $json->{userid} = '-1';
    }
    return $json;
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
