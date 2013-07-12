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

# returns a user's information
sub getUserInfo {
    my ($class, $email) = @_;
    
    #$controller->debug('before query');
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call get_user(:email)",
        {
            email => $email
        }
    );

    my $json = {};
    my $cols = $result->fetch; # get the columns (keys for json)
    
    my $userInfo = $result->fetch; # get the newly created user's info
    return {error => '1', txt => 'User does not exist'} unless ($userInfo->[0]); # user does not exist
    
    for(my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $userInfo->[$i];
    }

    return $json;
}

# inserts a new user into the DB
sub signup {
    my ($class, $params) = @_;
    
    my $pass = $params->{'password'};
    
    return {error => '3', txt => 'Password must be at least six characters'} if (length($pass) < 6); # password must be at least 6 characters
    return {error => '4', txt => 'Password must contain at least one number'} if ($pass !~ m/\d/);
    return {error => '5', txt => 'Valid password characters are alphanumeric or !@#$%^&*()'} if ($pass =~ m/[^A-Za-z0-9!@#\$%\^&\*\(\)]/); # limit character set to alphanumeric and !@#$%^&*()
    $pass = createSaltedHash($pass);
    
    my $result = AnnoTree::Model::MySQL->db->execute("call create_user(:password, :firstName, :lastName, :email, :lang, :timezone, :profileImage, :status)", 
        {
            email           => $params->{'email'}, 
            password        => '' . $pass,
            firstName       => $params->{'firstName'},
            lastName        => $params->{'lastName'},
            lang            => 'ENG',
            timezone        => 'EST',
            profileImage    => 'img/user.png',
            status          => '3'
        }
    );

    my $json = {};
    my $cols = $result->fetch; # get the columns (keys for json)
    if (looks_like_number($cols->[0])) { # if there is an error return
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Invalid email submitted'};
        } elsif ($error == 2) {
            return {error => $error, txt => 'Email already exists'};
        } 
    }
    my $userInfo = $result->fetch; # get the newly created user's info
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $userInfo->[$i];
    }
    
    return $json;
}

sub deleteUser {
    my ($class, $userid) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute("call delete_user(:userid)",
        {
            userid => $userid
        }
    );
    
    my $json = {};
    my $cols = $result->fetch; # get the columns (keys for json)
    
    return {error => $cols->[0]} if (looks_like_number($cols->[0])); # if there is an error return
    
    my $userInfo = $result->fetch; # get the newly created user's info
    for (my $i = 0; $i < @{$cols}; $i++) {
        $json->{$cols->[$i]} = $userInfo->[$i];
    }
    
    return $json;
}

sub knownPeople {
    my ($class, $user) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call get_users_in_shared_trees(:user)",
        {
            user => $user
        }
    );
    
    my $cols = $result->fetch;

    my $json = {users => []};
    my $userIndex = 0;
    while (my $return = $result->fetch) {
        for (my $i = 0; $i < @{$cols}; $i++) {
            $json->{users}->[$userIndex]->{$cols->[$i]} = $return->[$i];
        }
        $userIndex++;
    }

    return $json;
}

return 1;
