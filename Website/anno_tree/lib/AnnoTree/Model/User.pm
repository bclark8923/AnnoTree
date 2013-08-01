package AnnoTree::Model::User;

use Mojo::Base -strict;
use Crypt::SaltedHash;
use AnnoTree::Model::MySQL;
use AnnoTree::Model::Email;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP ();
use Email::Simple ();
use Email::Simple::Creator ();
use Config::General;
use Email::MIME;
use Digest::SHA qw(sha256_hex);
use Time::Piece ();

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;

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
    my $created = Time::Piece::localtime->strftime('%F %T');  
    my $token = sha256_hex($params->{email}, $created);
    
    my $result = AnnoTree::Model::MySQL->db->execute("call create_user(:password, :firstName, :lastName, :email, :lang, :timezone, :profileImage, :token, :created, :services)", 
        {
            email           => $params->{'email'}, 
            password        => '' . $pass,
            firstName       => $params->{'firstName'},
            lastName        => $params->{'lastName'},
            lang            => 'ENG',
            timezone        => 'EST',
            profileImage    => 'img/user.png',
            token           => $token,
            created         => $created,
            services        => $config{server}->{base_url} . '/services/annotation/'
        }
    );

    my $json = {};
    my $cols = $result->fetch; # get the columns (keys for json)
    if (looks_like_number($cols->[0])) { # if there is an error return
        my $error = $cols->[0];
        if ($error == 1) {
            return {error => $error, txt => 'Invalid email submitted'};
        } elsif ($error == 2) {
            return {error => $error, txt => 'You are already an active user. Please log in to continue.'};
        } elsif ($error == 6) {
            return {error => $error, txt => 'You have not been granted access to the beta yet. If you want immediate access please contact us at contact@annotree.com'};
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

# beta signup service
sub beta {
    my ($class, $email) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call create_beta_user(:email)",
        {
            email => $email
        }
    );

    my $json = {};
    my $num = $result->fetch->[0];
    if ($num == 0) {
        $json = {result => $num, txt => 'User added as inactive beta user'};
        
        my $from = '"AnnoTree" <invite@annotree.com>';
        my $subject = "Thanks for Signing Up for AnnoTree";
        my $message = "Thanks for signing up for the AnnoTree beta. We are currently rolling in users to test our platform and will reach out to you soon when we're ready to bring you on board.<br/><br/>In the meantime, we invite you to follow us on social media and at <a href=\"http://blog.annotree.com\">http://blog.annotree.com</a> to stay up-to-date on our product, our vision, and how AnnoTree will reshape the mobile development space.<br/><br/>If you have any questions, please feel free to reply to this email and we'll get back to you as soon as possible!";
        
        AnnoTree::Model::Email->mail($email, $from, $subject, $message);
    } elsif ($num == 1) {
        $json = {error => $num, txt => 'User already signed up for the beta and can sign in'};
    } elsif ($num == 2) {
        $json = {error => $num, txt => 'User has already been invited'};
    } elsif ($num == 3) {
        $json = {error => $num, txt => 'User is already active'};
    } elsif ($num == 4) {
        $json = {error => $num, txt => 'User is already signed up for beta'};
    } elsif ($num == 5) {
        $json = {error => $num, txt => 'Invalid email submitted'};
    } 

    return $json;
}

# emails feedback results
sub feedback {
    my ($class, $params) = @_;
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call get_user_by_id(:id)",
        {
            id => $params->{userid}
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    my $userInfo = $result->fetch;
    
    my $body = 'The following user has provided feedback:<br/>';
    for (my $i = 0; $i < @{$cols}; $i++) {
        $body .= $cols->[$i] . ': ' . $userInfo->[$i] . "<br/>";
    }
    $body .= "<br/>Feedback:<br/>" . $params->{feedback};

    my $to = $config{email}->{feedback};
    my $from = '"Feedback" <feedback@annotree.com>';
    my $subject = 'Feedback';
    
    AnnoTree::Model::Email->mail($to, $from, $subject, $body);
}

# let's an user apply to reset their password
sub setReset {
    my ($class, $email) = @_;

    my $result = AnnoTree::Model::MySQL->db->execute(
        "call request_password(:email)",
        {
            email => $email
        }
    );

    my $json = {};
    my $cols = $result->fetch;
    return {error => $cols->[0], txt => 'Email does not exist or user is not active'} if (looks_like_number($cols->[0]));
    my $userInfo = $result->fetch;
    my $name = $userInfo->[1] || $userInfo->[2];

    my $token = sha256_hex($email, $userInfo->[0]);
    
    AnnoTree::Model::MySQL->db->execute(
        "call create_reset_token(:email, :token)",
        {
            email   => $email,
            token   => $token
        }
    );
 
    my $link = $config{server}->{base_url} . '/#/authenticate/resetPassword?token=' . $token;
    my $message = "Hi $name,<br/><br/>You have requested to reset your password. You can reset your password by clicking <a href=\"$link\">$link</a>. This link will only be valid for 1 hour.<br/><br/>If you did not request to reset your password you can ignore this message.";
    my $from = '"AnnoTree Support" <support@annotree.com>';
    my $subject = 'AnnoTree Password Reset';

    AnnoTree::Model::Email->mail($email, $from, $subject, $message);
}

# resets the user's password
sub reset {
    my ($class, $params) = @_;

    my $pass = $params->{password};
    return {error => '3', txt => 'Password must be at least six characters'} if (length($pass) < 6); # password must be at least 6 characters
    return {error => '4', txt => 'Password must contain at least one number'} if ($pass !~ m/\d/);
    return {error => '5', txt => 'Valid password characters are alphanumeric or !@#$%^&*()'} if ($pass =~ m/[^A-Za-z0-9!@#\$%\^&\*\(\)]/); # limit character set to alphanumeric and !@#$%^&*()
    $pass = createSaltedHash($pass);
    
    my $result = AnnoTree::Model::MySQL->db->execute(
        "call reset_password(:pass, :token)",
        {
            token   => $params->{token},
            pass    => $pass
        }
    );

    my $json = {};
    my $num = $result->fetch->[0];
    if ($num == 0) {
        $json = {result => $num, txt => 'User password successfully reset'};
    } elsif ($num == 1) {
        $json = {error => $num, txt => 'We have no records of you wishing to reset your password.'};
    } elsif ($num == 2) {
        $json = {error => $num, txt => 'Time has expired to reset your password.'};
    }
    
    return $json;
}

return 1;
