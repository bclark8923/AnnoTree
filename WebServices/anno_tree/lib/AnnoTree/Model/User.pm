package AnnoTree::Model::User;

use Mojo::Base -strict;
use Crypt::SaltedHash;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;

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
# returns 1 if password is incorrect
# returns the user's info in a hash otherwise
sub login {
    my ($controller, $params) = @_;
    
    #$controller->debug('before query');
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call get_user(:email)",
        {
            email => $params->{email}
        }
    );

    my $json = {};
    my $cols = $result->fetch; # get the columns (keys for json)
    
    my $userInfo = $result->fetch; # get the newly created user's info
    return {error => '1'} unless ($userInfo->[0]); # user does not exist
    
    for(my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $userInfo->[$i];
    }
    my $shash = $json->{password};
    my $valid = Crypt::SaltedHash->validate($shash, $params->{password});
    return {error => '0'} unless ($valid); # passwords do not match
    
    return $json;
}

# inserts a new user into the DB
sub signup {
    my ($class, $params) = @_;
    
    my $pass = $params->{'password'};
    
    return 3 if (length($pass) < 6); # password must be at least 6 characters
    return 4 if ($pass !~ m/\d/);
    return 5 if ($pass =~ m/[^A-Za-z0-9!@#\$%\^&\*\(\)]/); # limit character set to alphanumeric and !@#$%^&*()
    $pass = createSaltedHash($pass);
    
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
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $userInfo->[$i];
    }
    
    return $json;
}

sub deleteUser {
    my ($class, $userid) = @_;
    
    print "userid to delete is $userid \n";
    my $result = AnnoTree::Model::MySQL->db->execute("call delete_user(:userid)",
        {
            userid => $userid
        }
    );
    
    my $json = {};
    my $cols = $result->fetch; # get the columns (keys for json)
    print Dumper($cols);
    return {error => $cols->[0]} if (looks_like_number($cols->[0])); # if there is an error return
    
    my $userInfo = $result->fetch; # get the newly created user's info
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $userInfo->[$i];
    }
    
    return $json;
}

return 1;
