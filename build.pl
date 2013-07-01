#!/usr/bin/env perl

package Build;

use Getopt::Long;
use Modern::Perl '2013';
use AppConfig;

# grab the inforamtion from the configuration file
my $config = AppConfig->new();
$config->define('server=s');
$config->define('port=s');
$config->define('screenshot=s');
$config->define('annotationpath=s');
$config->define('devRoot=s');
$config->file('/opt/config.txt');

my $port = $config->get('port');
my $server = $config->get('server');
my $root = $config->get('devRoot');

# set and verify all the passed in arguments and initialize the program
my $verbose;
my $server;
my $action;
my $environment;
my $repo;
my $log;
my $help;
my $branch;

GetOptions(
    'verbose'           => \$verbose,
    'action|a=s'        => \$action,
    'environment|e=s'   => \$environment,
    'log|l=s'           => \$log,
    'repo|r=s'          => \$repo,
    'help|h'            => \$help,
    'branch|b'          => \$branch
) or die("Error in the supplied arguments. Please see build.pl -h for more information.\n");

usage() and exit 0 if $help;
usage() and exit 0 unless ($server && $action);

($branch = 'master') unless defined $branch;

if ($server eq 'awsdev') {
    $root = $awsdevRoot;
} elsif ($server eq 'matt') {
    $root = $mattRoot;
} else {
    usage() and exit 0;
}
$log ? open(OUTPUT, '>', "$root/$log") : open(OUTPUT, '>&', \*STDOUT);
my $mojoScript = $root . '/Website/anno_tree/script/anno_tree';
say OUTPUT 'Path to GIT repository root is: ' . $root if $verbose;

if ($action eq 'pull') {
    usage() and exit 0 unless $repo;
    pull();
} elsif ($action eq 'restart') {
    restart();
} elsif ($action eq 'rebuild') {
    rebuild();
} elsif ($action eq 'test') {
    test();
} elsif ($action eq 'flush') {
    usage() and exit 0 unless $repo;
    flush();
} else {
    usage() and exit 0;
}

# prints the help menu
sub usage {
    say "Usage: build.pl [options]";
    say "---REQUIRED---";
    say "\t-a, --action (pull, restart, rebuild, flush)";
    say "\t\tpull: grabs the latest information from the git repo (-r is required for this)";
    say "\t\trestart: (re)starts the development server";
    say "\t\trebuild: reinitializes the DB";
    say "\t\ttest: run the unit tests for the services";
    say "\t\tflush: pull, rebuild, (re)start, and test (-r required for this)";
    say "--OPTIONAL--";
    say "\t-r, --repo";
    say "\t\tname of the remote git repository";
    say "\t-b, --branch";
    say "\t\tbranch to pull (master if not specified)";
    say "\t-e, --environment";
    say "\t\twhat environment is running, defaults to dev (prod, dev)";
    say "\t-l, --log [file]";
    say "\t\tname of the file to write to";
    say "\t-v, --verbose";
    say "\t\tinclude messages to STDOUT about what the script is doing";
    say "\t-h, --help";
    say "\t\tprints this message";
}

# grabs the lastest code from the specified branch (master if branch is not given)
sub pull {
    say OUTPUT 'Preparing to pull code from the remote git repo ' . $repo . ' and branch ' . $branch if $verbose;
    if ($server eq 'http://23.21.235.254') {
        `sudo chown -R matt:dev $root/*`;
        `sudo chown -R matt:dev $root/.git`;
        `git stash`;
    }
    open(GIT, '<', `git pull $repo $branch |`);
    while (my $line = <GIT>) {
        print $line;
    }
}

# (re)starts the hypnotoad or morbo server
sub restart {
    say OUTPUT 'Preparing to restart server' if $verbose;
    my @netstat = `sudo netstat -tupln`;
    my $port = (defined $environment && $environment eq 'prod' ? '8080' : '3000');
    my $serverRunning = 0;
    foreach my $line (@netstat) {
        next unless $line =~ m/(:8080).+(\/anno_tree)/ || $line =~ m/(:3000).+(\/perl)/;
        my ($process) = $line =~ m/(\d+)\/[perl|anno_tree]/;
        say OUTPUT 'Server process is: ' . $process if $verbose;
        `sudo kill $process`;
        $serverRunning = 1;
    }
    say OUTPUT 'No server was found running' if $verbose && !$serverRunning;
    my $serverCmd = (defined $environment && $environment eq 'prod' ? 'hypnotoad' : 'morbo');
    `nohup $serverCmd $mojoScript > $serverCmd.out 2>&1 &`;
    say OUTPUT 'Server restarted' if $verbose;
}

sub rebuild {
    say OUTPUT 'Preparing to rebuild DB' if $verbose;
    chdir "$root/Database/";
    $log ? `./install.py >> $root/$log` : `./install.py`;
}

sub test {
    say OUTPUT 'Preparing to start web services\' tests' if $verbose;
    $log ? `$mojoScript test -v >> $root/$log 2>&1` : `$mojoScript test -v 1>&2`;
}

sub flush {
    pull();
    rebuild();
    restart();
    test();
}


