package AnnoTree::Model::User;

use Mojo::Base -strict;
use Crypt::SaltedHash;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);

# creates a salted hash which is returned
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
    my ($controller, $params) = @_;
    
    #$controller->debug('before query');
    my $result = AnnoTree::Model::MySQL->db->execute(
        "select get_user(:email)",
        {
            email => $params->{email}
        }
    );
    my $fetch = $result->fetch;
    my $json = {};
    
    if ($fetch->[0]) {
        my @fetch = split(/, /, $fetch->[0]);
        #$controller->debug('userid: ' . $fetch[0]);
        $controller->debug($controller->dumper($fetch));
        my $shash = $fetch[1];
        my $valid = Crypt::SaltedHash->validate($shash, $params->{password});
        $controller->debug("valid is $valid");
        
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
    my ($class, $params) = @_;
    
    my $pass = createSaltedHash($params->{'password'});
    
    my $result = AnnoTree::Model::MySQL->db->execute("call create_user(:password, :firstName, :lastName, :email, :lang, :timezone, :profileImage)", 
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

    my $json = {};
    my $cols = $result->fetch; # get the columns (keys for json)
    return $cols->[0] if (looks_like_number($cols->[0])); # if there is an error return
    
    my $userInfo = $result->fetch; # get the newly created user's info
    for(my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $userInfo->[$i];
    }
    
    return $json;
}

return 1;
