#! /usr/bin/env perl

use DBIx::Custom;
use Config::General;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP ();
use Time::Piece ();
use Data::Dumper;

# 
my $created = Time::Piece::localtime->strftime('%F');
my $date = substr($created, 0, 8) . (substr($created, 8, 2) - 1);

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;

# Database set up
my $dsn = 'dbi:mysql:database=annotree;host=' . $config->{data}->{server} . ';port=' . $config->{database}->{port};

my $db = DBIx::Custom->connect(
    dsn         => $dsn,
    user        => 'annotree',
    password    => 'ann0tr33s',
    connector   => 1
) or die 'Could not connect to DB';

$db->{mysql_auto_reconnect} = 1;

# stores the message (analytics information) contents
my $message = '';

# Total number of users on the CCP
my $result = $db->execute(
    "select count(*) from user"
);

my $numTotalUsers = $result->fetch->[0];

$message .= '<span style="font-weight:bold">Total Number of Users</span>:' . $numTotalUsers . '<br/>';

print $date . "\n";

$result = $db->execute(
    "select email, first_name, last_name, created_at, signup_date, last_login, status from user where last_login > :date",
    {
        date => $date
    }
);

$message .= '<table class="borderTable"><tr><td>Email</td><td>First Name</td><td>Last Name</td><td>Created Date</td><td>Signup Date</td><td>Last Login Date</td><td>State</td></tr>';
while (my $index = $result->fetch) {
    #print Dumper($index);
    $message .= '<tr>';
    for (my $i = 0; $i < @{$index}; $i++) {
        $message .= '<td>' . $index->[$i] . '</td>';
    }
    $message .= '</tr>';
}
$message .= '</table>';
#=begin code
# Send the email
my $smtpserver = 'smtp.mailgun.org';
my $smtpport = 587;
my $smtpuser = 'postmaster@annotree.com';
my $smtppassword = '8-7sigqno8u7';

my @parts = (
    Email::MIME->create(
        attributes => {
            content_type => "text/html"
        },
        body => "<html><head></head><body><table ><tr><td><img src=\"http://annotree.com/Email/HeaderLeft.png\" border=\"0\" alt=\"\" /><a href=\"http://annotree.com\"><img style=\"float:right\" src=\"http://annotree.com/Email/HeaderRight.png\" border=\"0\" alt=\"AnnoTree\" /></a></td></tr><tr><td>$message<br/><br/>Sincerely,<br/>Your Friendly Analytics Bot<br/><br/></td></tr></table></body></html>"
    )
);

my $transport = Email::Sender::Transport::SMTP->new({
    host          => $smtpserver,
    port          => $smtpport,
    sasl_username => $smtpuser,
    sasl_password => $smtppassword
});

my $emailObj = Email::MIME->create(
    header => [
        To              => 'lordoftheservers@silith.io',
        From            => 'analyticsbot@annotree.com',
        Subject         => 'Daily User Extract for ',
        content_type    => 'multipart/mixed'
    ],
    parts => [@parts]
);

sendmail($emailObj, { transport => $transport });
#=end code
#=cut
