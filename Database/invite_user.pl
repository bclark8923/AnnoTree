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

my $smtpserver = 'smtp.mailgun.org';
my $smtpport = 587;
my $smtpuser = 'postmaster@annotree.com';
my $smtppassword = '8-7sigqno8u7';

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

open(INVITEES, '<', $config{email}->{inviteUsers}) or die;

my $transport = Email::Sender::Transport::SMTP->new({
    host          => $smtpserver,
    port          => $smtpport,
    sasl_username => $smtpuser,
    sasl_password => $smtppassword
});

my $log = '';

while (my $user = <INVITEES>) {
    chomp $user;
    print "$user\n";

    my $result = $db->execute(
        "SELECT status FROM user WHERE email = :email",
        {
            email => $user,
        }
    );
    
    my $status = $result->fetch;
    $log .= "User $user does not exist in the database.<br/>" and next unless $status;
    $log .= "User $user has status $status->[0] and was not flipped.<br/>" and next unless $status->[0] == 0;
    $log .= "User $user being flipped and invited.<br/>";

    $db->execute(
        "UPDATE user SET status = 1 WHERE email = :email",
        {
            email => $user,
        }
    );
    
    my $message .= '<h2 style="margin:0;padding:0;display:block;font-family:Helvetica;font-size:26px;font-style:normal;font-weight:bold;line-height:125%;letter-spacing:-.75px;text-align:left;color:#404040!important">Welcome to AnnoTree</h2>';
    $message .= '<h4 style="margin:0;padding:0;display:block;font-family:Helvetica;font-size:16px;font-style:normal;font-weight:bold;line-height:125%;letter-spacing:normal;text-align:left;color:#808080!important">Join the Private Beta Today!</h4>';
    $message .= '<p>Hello,</p>';
    $message .= '<p>AnnoTree is now in private beta, and we are excited to give you the opportunity to get a first look at our new product.</p>';
    $message .= '<p>As a reminder, AnnoTree is a platform designed for you and your team to identify bugs or design changes directly on a mobile or web application and collaborate on these annotations with your team.</p>';
    $message .= '<p>You can join AnnoTree via the button below:</p>';
    $message .= '<table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">';
    $message .= '<tbody><tr><td style="padding-top:0;padding-right:18px;padding-bottom:18px;padding-left:18px" valign="top" align="center">';
    $message .= '<table border="0" cellpadding="0" cellspacing="0" style="border-top-left-radius:5px;border-top-right-radius:5px;border-bottom-right-radius:5px;border-bottom-left-radius:5px;background-color:#5cc080;border-collapse:collapse">';
    $message .= '<tbody><tr>';
    $message .= '<td align="center" valign="middle" style="font-family:Arial;font-size:18px;padding:20px">';
    $message .= '<a title="Signup Now!" href="https://ccp.annotree.com/#/authenticate/signUp?email=' . $user . '" style="font-weight:bold;letter-spacing:-0.5px;line-height:100%;text-align:center;text-decoration:none;color:#ffffff;word-wrap:break-word" target="_blank">Signup Now!</a>';
    $message .= '</td></tr></tbody></table></td></tr></tbody></table>';

    my $footer = '<table border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse">
                    <tbody>
                        <tr>
                            <td valign="top" style="padding-top:9px;padding-right:9px;padding-left:9px">
                                <table align="left" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse">
                                    <tbody>
                                        <tr>
                                            <td valign="top" style="padding-right:10px;padding-bottom:9px">
                                                <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
                                                    <tbody>
                                                        <tr>
                                                            <td align="left" valign="middle" style="padding-top:5px;padding-right:10px;padding-bottom:5px;padding-left:9px">
                                                                <table align="left" border="0" cellpadding="0" cellspacing="0" width="" style="border-collapse:collapse">
                                                                    <tbody>
                                                                        <tr>
                                                                            <td align="center" valign="middle" width="18">
                                                                                <a href="https://www.facebook.com/annotreeapp" style="word-wrap:break-word" target="_blank"><img src="http://annotree.com/Email/facebook.png" style="display:block;border:0;outline:none;text-decoration:none" height="24" width="24"></a>
                                                                            </td>
                                                                            <td align="left" valign="middle" style="padding-left:5px">
                                                                                <a href="https://www.facebook.com/annotreeapp" style="font-family:Arial;font-size:11px;text-decoration:none;color:#5cc080;font-weight:normal;line-height:100%;text-align:center;word-wrap:break-word" target="_blank">Facebook</a>
                                                                            </td>
                                                                        </tr>
                                                                    </tbody>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                                <table align="left" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse">
                                    <tbody>
                                        <tr>
                                            <td valign="top" style="padding-right:10px;padding-bottom:9px">
                                                <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
                                                    <tbody>
                                                        <tr>
                                                            <td align="left" valign="middle" style="padding-top:5px;padding-right:10px;padding-bottom:5px;padding-left:9px">
                                                                <table align="left" border="0" cellpadding="0" cellspacing="0" width="" style="border-collapse:collapse">
                                                                    <tbody>
                                                                        <tr>
                                                                            <td align="center" valign="middle" width="18">
                                                                                <a href="https://twitter.com/annotree" style="word-wrap:break-word" target="_blank"><img src="http://annotree.com/Email/twitter.png" style="display:block;border:0;outline:none;text-decoration:none" height="24" width="24"></a>
                                                                            </td>
                                                                            <td align="left" valign="middle" style="padding-left:5px">
                                                                                <a href="https://twitter.com/annotree" style="font-family:Arial;font-size:11px;text-decoration:none;color:#5cc080;font-weight:normal;line-height:100%;text-align:center;word-wrap:break-word" target="_blank">Twitter</a>
                                                                            </td>
                                                                        </tr>
                                                                    </tbody>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                                <table align="left" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse">
                                    <tbody>
                                        <tr>
                                            <td valign="top" style="padding-right:10px;padding-bottom:9px">
                                                <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
                                                    <tbody>
                                                        <tr>
                                                            <td align="left" valign="middle" style="padding-top:5px;padding-right:10px;padding-bottom:5px;padding-left:9px">
                                                                <table align="left" border="0" cellpadding="0" cellspacing="0" width="" style="border-collapse:collapse">
                                                                    <tbody>
                                                                        <tr>
                                                                            <td align="center" valign="middle" width="18">
                                                                                <a href="http://www.annotree.com" style="word-wrap:break-word" target="_blank"><img src="http://annotree.com/Email/website.png" style="display:block;border:0;outline:none;text-decoration:none" height="24" width="24"></a>
                                                                            </td>
                                                                            <td align="left" valign="middle" style="padding-left:5px">
                                                                                <a href="http://www.annotree.com" style="font-family:Arial;font-size:11px;text-decoration:none;color:#5cc080;font-weight:normal;line-height:100%;text-align:center;word-wrap:break-word" target="_blank">Website</a>
                                                                            </td>
                                                                        </tr>
                                                                    </tbody>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                                <table align="left" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse">
                                    <tbody>
                                        <tr>
                                            <td valign="top" style="padding-right:10px;padding-bottom:9px">
                                                <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
                                                    <tbody>
                                                        <tr>
                                                            <td align="left" valign="middle" style="padding-top:5px;padding-right:10px;padding-bottom:5px;padding-left:9px">
                                                                <table align="left" border="0" cellpadding="0" cellspacing="0" width="" style="border-collapse:collapse">
                                                                    <tbody>
                                                                        <tr>
                                                                            <td align="center" valign="middle" width="18">
                                                                                <a href="mailto:hello@annotree.com" style="word-wrap:break-word" target="_blank"><img src="http://annotree.com/Email/emailForward.png" style="display:block;border:0;outline:none;text-decoration:none" height="24" width="24"></a>
                                                                            </td>
                                                                            <td align="left" valign="middle" style="padding-left:5px">
                                                                                <a href="mailto:hello@annotree.com" style="font-family:Arial;font-size:11px;text-decoration:none;color:#5cc080;font-weight:normal;line-height:100%;text-align:center;word-wrap:break-word" target="_blank">Email</a>
                                                                            </td>
                                                                        </tr>
                                                                    </tbody>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                        </tbody>
                                                    </table>
                                                </td>
                                            </tr>
                                    </tbody>
                                </table>
                                <table align="left" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse">
                                    <tbody>
                                        <tr>
                                            <td valign="top" style="padding-right:0;padding-bottom:9px">
                                                <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse:collapse">
                                                    <tbody>
                                                        <tr>
                                                            <td align="left" valign="middle" style="padding-top:5px;padding-right:10px;padding-bottom:5px;padding-left:9px">
                                                                <table align="left" border="0" cellpadding="0" cellspacing="0" width="" style="border-collapse:collapse">
                                                                    <tbody>
                                                                        <tr>
                                                                            <td align="center" valign="middle" width="18">
                                                                                <a href="http://vimeo.com/75744148" style="word-wrap:break-word" target="_blank"><img src="http://annotree.com/Email/video.png" style="display:block;border:0;outline:none;text-decoration:none" height="24" width="24"></a>
                                                                            </td>
                                                                            <td align="left" valign="middle" style="padding-left:5px">
                                                                                <a href="http://vimeo.com/75744148" style="font-family:Arial;font-size:11px;text-decoration:none;color:#5cc080;font-weight:normal;line-height:100%;text-align:center;word-wrap:break-word" target="_blank">Video</a>
                                                                            </td>
                                                                        </tr>
                                                                    </tbody>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                    </tbody>
                </table>';

    my @parts = (
        Email::MIME->create(
            attributes => {
                content_type => "text/html"
            },
            body => "<html>
                        <head></head>
                        <body>
                            <table align=\"center\" style=\"font-size:12pt;font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;color:#595959;background-color:#444;padding:30px;width:100%\">
                                <tr>
                                    <td>
                                        <table align=\"center\" style=\"width:600px;padding:20px;background-color:#fff\">
                                            <tr>
                                                <td>
                                                    <a href=\"http://annotree.com\">
                                                        <img src=\"http://annotree.com/Email/AnnoTreeLogoName.png\" border=\"0\" alt=\"\" />
                                                    </a>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    $message<br/><br/>
                                                    Sincerely,<br/>
                                                    The AnnoTree Team<br/><br/>
                                                    Want to learn more?  Check us out on:</br><br/>
                                                    $footer
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                <tr>
                            </table>
                        </body>
                    </html>"
        )
    );

    my $emailObj = Email::MIME->create(
        header => [
            To              => $user,
            From            => '"AnnoTree" <hello@annotree.com>',
            Subject         => "Welcome to AnnoTree",
            content_type    => 'multipart/mixed'
        ],
        parts => [@parts]
    );

    sendmail($emailObj, { transport => $transport });
}

close(INVITEES);

my @parts = (
    Email::MIME->create(
        attributes => {
            content_type => "text/html"
        },
        body => $log
    )
);

# inform me what just happenened in case anything happened
my $emailObj = Email::MIME->create(
    header => [
        To              => 'lordoftheservers@silith.io',
        From            => '"AnnoTree" <hello@annotree.com>',
        Subject         => "Status of flipped users",
        content_type    => 'multipart/mixed'
    ],
    parts => [@parts]
);

sendmail($emailObj, { transport => $transport });
