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

    # TODO: view for body / minimum split up on diff lines
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
                                                    $message
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
