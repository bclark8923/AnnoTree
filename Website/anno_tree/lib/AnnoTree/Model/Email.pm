package AnnoTree::Model::Email;

use Mojo::Base -strict;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP ();

sub mail {
    my ($class, $to, $from, $subject, $message) = @_;

    my $smtpserver = 'smtp.mailgun.org';
    my $smtpport = 587;
    my $smtpuser = 'postmaster@annotree.com';
    my $smtppassword = '8-7sigqno8u7';

    my @parts = (
        Email::MIME->create(
            attributes => {
                content_type => "text/html"
            },
            body => "<html><head></head><body><table style=\"font-size:12pt;font-family:Lato Light,sans-serif;color:#898989\"><tr><td><img src=\"http://annotree.com/Email/HeaderLeft.png\" border=\"0\" alt=\"\" /><a href=\"http://annotree.com\"><img style=\"float:right\" src=\"http://annotree.com/Email/HeaderRight.png\" border=\"0\" alt=\"AnnoTree\" /></a></td></tr><tr><td>$message<br/><br/>Sincerely,<br/>The AnnoTree Team<br/><br/><a href=\"https://www.facebook.com/annotreeapp\"><img src=\"http://annotree.com/Email/facebook.png\" height=\"30\" width=\"30\" border=\"0\" alt=\"Facebook\" /></a>  <a href=\"https://twitter.com/AnnoTree\"><img src=\"http://annotree.com/Email/twitter.png\" height=\"30\" width=\"30\" border=\"0\" alt=\"Twitter\" /></a></td></tr></table></body></html>"
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
            To              => $to,
            From            => $from,
            Subject         => $subject,
            content_type    => 'multipart/mixed'
        ],
        parts => [@parts]
    );

    sendmail($emailObj, { transport => $transport });
}

return 1;
