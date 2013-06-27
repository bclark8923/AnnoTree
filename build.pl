#!/usr/bin/env perl

package Build;

use Getopt::Long;
use Modern::Perl '2013';

# root path to the location of the GIT repo
my $root = '';
my $awsdevRoot = '/opt/www';
my $mattRoot = '/home/matt/reserve/AnnoTree';

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
    'server|s=s'        => \$server,
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
    say "\t-s, --server (awsdev, matt)";
    say "\t\tserver that the script is running on";
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
    if ($server eq 'awsdev') {
        `sudo chown -r matt:dev $root/*`;
        `sudo chown -r matt:dev $root/.git`;
        `git stash`;
    }
    `git pull $repo $branch`;
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


