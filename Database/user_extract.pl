#! /usr/bin/env perl

use DBIx::Custom;
use Config::General;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP ();
use Time::Piece ();
use Data::Dumper;

use strict;
use warnings;

### subroutines ###
sub createTableHeaders {
    my $headerNames = shift;

    my $header = '<tr>';
    for (my $i = 0; $i < @{$headerNames}; $i++) {
        $header .= '<th style="background-color:#92DF74;color:#fff;padding:5px">';
        $header .= $headerNames->[$i];
        $header .= '</th>';
    }
    $header .= '</tr>';
    return $header;
}

# Current date information
my $created = Time::Piece::localtime->strftime('%F');
my $date = substr($created, 0, 8) . (substr($created, 8, 2) - 1);
my $dateLastWeek = substr($created, 0, 8) . (substr($created, 8, 2) - 7);

# Get the configuration settings
my $conf = Config::General->new('/opt/config.txt');
my %config = $conf->getall;

# Database set up
my $dsn = 'dbi:mysql:database=annotree;host=' . $config{database}->{server} . ';port=' . $config{database}->{port};

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

# Total number of new users since yesterday
$result = $db->execute(
    "select count(*) from user where created_at > :date", 
    {
        date => $date
    }
);
my $numNewUsers = $result->fetch->[0];

# Total number of new users since last week
$result = $db->execute(
    "select count(*) from user where created_at > :date", 
    {
        date => $dateLastWeek
    }
);
my $numPastWeekUsers = $result->fetch->[0];

my $usersPast = ($numTotalUsers - $numNewUsers) || 1;
my $pastDayGrowthRate = (($numTotalUsers - $usersPast) / $usersPast) * 100;
$usersPast = ($numTotalUsers - $numPastWeekUsers) || 1;
my $pastWeekGrowthRate = (($numTotalUsers - $usersPast) / $usersPast) * 100;

$message .= '<span style="font-weight:bold">Total number of users</span>: ' . $numTotalUsers  . '<br/>';
$message .= '<span style="font-weight:bold">Users created since yesterday</span>: ' . $numNewUsers . ' (' . $pastDayGrowthRate . '%)<br/>';
$message .= '<span style="font-weight:bold">Users created in the past week</span>: ' . $numPastWeekUsers . ' (' . $pastWeekGrowthRate . '%)<br/>';

$message .= '<span style="font-weight:bold">Total number of ___ created since ' . $date . ' -</span><br/>';

# Trees created in the past day
$result = $db->execute(
    "select count(*) from tree where created_at > :date",
    {
        date => $date
    }
);

my $numCreatedTrees = $result->fetch->[0];

$message .= '<span style="font-weight:bold">Trees</span>: ' . $numCreatedTrees . '<br/>';

# Leaves created in the past day
$result = $db->execute(
    "select count(*) from leaf where created_at > :date",
    {
        date => $date
    }
);

my $numCreatedLeaves = $result->fetch->[0];

$message .= '<span style="font-weight:bold">Leaves</span>: ' . $numCreatedLeaves . '<br/>';

# Annotations created in the past day
$result = $db->execute(
    "select count(*) from annotation where created_at > :date",
    {
        date => $date
    }
);

my $numCreatedAnnotations = $result->fetch->[0];

$message .= '<span style="font-weight:bold">Annotations</span>: ' . $numCreatedAnnotations . '<br/><br/>';

# Get user information for the users that have logged on in the past day
$result = $db->execute(
    "select email, first_name, last_name, created_at, signup_date, last_login, status from user where last_login > :date",
    {
        date => $date
    }
);

$message .= '<span style="font-weight:bold">People who logged in since ' . $date . '</span>:<br/>';
$message .= '<table style="border:1px solid #000;text-align:center;margin-bottom:15px">' . createTableHeaders([
        'Email',
        'First Name',
        'Last Name',
        'Created',
        'Signup',
        'Last Login',
        'Status'
    ]);
while (my $info = $result->fetch) {
    $message .= '<tr>';
    for (my $i = 0; $i < @{$info}; $i++) {
        $message .= '<td style="border: 1px solid #000;text-align:center;padding:5px">' . $info->[$i] . '</td>';
    }
    $message .= '</tr>';
}
$message .= '</table>';

# Users created in the past day
$result = $db->execute(
    "select email, first_name, last_name, created_at, signup_date, last_login, status from user where created_at > :date",
    {
        date => $date
    }
);

$message .= '<span style="font-weight:bold">People created since ' . $date . '</span>:<br/>';
$message .= '<table style="border:1px solid #000;text-align:center;margin-bottom:15px">' . createTableHeaders([
        'Email',
        'First Name',
        'Last Name',
        'Created',
        'Signup',
        'Last Login',
        'Status'
    ]);
while (my $info = $result->fetch) {
    $message .= '<tr>';
    for (my $i = 0; $i < @{$info}; $i++) {
        $message .= '<td style="border: 1px solid #000;text-align:center;padding:5px">' . $info->[$i] . '</td>';
    }
    $message .= '</tr>';
}
$message .= '</table>';

# Get beta users
$result = $db->execute(
    "select email, created_at from user where status = 0",
    {
        date => $date
    }
);

$message .= '<span style="font-weight:bold">Beta users</span>:<br/>';
$message .= '<table style="border:1px solid #000;text-align:center;margin-bottom:15px">' . createTableHeaders([
        'Email',
        'Created'
    ]);
while (my $info = $result->fetch) {
    $message .= '<tr>';
    for (my $i = 0; $i < @{$info}; $i++) {
        $message .= '<td style="border: 1px solid #000;text-align:center;padding:5px">' . $info->[$i] . '</td>';
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
        body => "<!DOCTYPE html><html><head></head>
                    <body>
                        <table >
                            <tr>
                                <td>
                                    <img src=\"http://annotree.com/Email/HeaderLeft.png\" border=\"0\" alt=\"\" />
                                    <a href=\"http://annotree.com\"><img style=\"float:right\" src=\"http://annotree.com/Email/HeaderRight.png\" border=\"0\" alt=\"AnnoTree\" /></a>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    $message<br/><br/>
                                    Sincerely,<br/>Your Friendly Analytics Bot<br/><br/>
                                </td>
                            </tr>
                        </table>
                    </body>
                </html>"
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
        To              => $config{email}->{analytics},
        From            => '"AnnoTree Analytics" <analyticsbot@annotree.com>',
        Subject         => 'Daily User Extract for ' . $date,
        content_type    => 'multipart/mixed'
    ],
    parts => [@parts]
);

sendmail($emailObj, { transport => $transport });
#=end code
#=cut
