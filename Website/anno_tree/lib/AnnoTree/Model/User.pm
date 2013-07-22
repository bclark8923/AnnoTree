package AnnoTree::Model::User;

use Mojo::Base -strict;
use Crypt::SaltedHash;
use AnnoTree::Model::MySQL;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP ();
use Email::Simple ();
use Email::Simple::Creator ();
use Config::General;

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

        my $smtpserver = 'smtp.mailgun.org';
        my $smtpport = 587;
        my $smtpuser   = 'postmaster@annotree.com';
        my $smtppassword = '8-7sigqno8u7';

        my $transport = Email::Sender::Transport::SMTP->new({
          host => $smtpserver,
          port => $smtpport,
          sasl_username => $smtpuser,
          sasl_password => $smtppassword,
        });

        my $email = Email::Simple->create(
          header => [
            To      => $email,
            From    => 'invite@annotree.com',
            Subject => 'Thanks for Signing Up for AnnoTree',
          ],
          body => "Hi,\n\nThanks for signing up to use the AnnoTree beta. We will let you know when you can join the AnnoTree beta and get started.\n\nSincerely,\nThe AnnoTree Team"
        );

        sendmail($email, { transport => $transport });
    } elsif ($num == 1) {
        $json = {error => $num, txt => 'User can sign up'};
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
    
    my $body = 'The following user has provided feedback:' . "\n";
    for (my $i = 0; $i < @{$cols}; $i++) {
        $body .= $cols->[$i] . ': ' . $userInfo->[$i] . "\n";
    }
    $body .= "\nFeedback:\n" . $params->{feedback};
    $body .= "\n\nSincerely,\nYour Local Feedback Bot";

    my $smtpserver = 'smtp.mailgun.org';
    my $smtpport = 587;
    my $smtpuser   = 'postmaster@annotree.com';
    my $smtppassword = '8-7sigqno8u7';

    my $transport = Email::Sender::Transport::SMTP->new({
      host => $smtpserver,
      port => $smtpport,
      sasl_username => $smtpuser,
      sasl_password => $smtppassword,
    });

    my $email = Email::Simple->create(
      header => [
        To      => $config{email}->{feedback},
        From    => '"Feedback" <feedback@annotree.com>',
        Subject => 'Feedback',
      ],
      body => $body
    );

    sendmail($email, {transport => $transport}); 
}

return 1;
