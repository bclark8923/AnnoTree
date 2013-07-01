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
usage() and exit 0 unless ($action);

($branch = 'master') unless defined $branch;

$log ? open(OUTPUT, '>', "$root/$log") : open(OUTPUT, '>&', \*STDOUT);
my $mojoScript = $root . '/Website/anno_tree/script/anno_tree';
say OUTPUT 'Path to GIT repository root is: ' . $root if ($verbose && ($action eq 'pull' || $action eq 'flush'));

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
        say OUTPUT 'Fixing permissions' if $verbose;
        my @text = `sudo chown -R matt:dev $root/*`;
        if ($verbose) {
            foreach my $line (@text) {
                print OUTPUT $line;
            }
        }
        @text = `sudo chown -R matt:dev $root/.git`;
        if ($verbose) {
            foreach my $line (@text) {
                print OUTPUT $line;
            }
        }
        say OUTPUT 'Stashing any changes to local files' if $verbose;
        @text = `git stash`;
        if ($verbose) {
            foreach my $line (@text) {
                print OUTPUT $line;
            }
        }
    }
    my @gitText = `git pull $repo $branch`;
    if ($verbose) {
        foreach my $line (@gitText) {
            print OUTPUT $line;
        }
    }
    say OUTPUT 'Done pulling code from the remote git repo' if $verbose;
}

# returns the process ID of the web server if it is running
sub checkServerRunning {
    my @netstat = `sudo netstat -tupln`;
    foreach my $line (@netstat) {
        next unless $line =~ m/(:8080).+(\/anno_tree)/ || $line =~ m/(:3000).+(\/perl)/;
        my ($process) = $line =~ m/(\d+)\/[perl|anno_tree]/;
        say OUTPUT 'Server running with process ID: ' . $process if $verbose;
        return $process;
    }
    return '';
}

# (re)starts the hypnotoad or morbo server
sub restart {
    say OUTPUT 'Preparing to restart server' if $verbose;
    my $servPort = $port;
    if (defined $environment && $environment eq 'prod') {
        $servPort = '8080';
    } elsif (defined $environment && $environment eq 'dev') {
        $servPort = '3000';
    }
    my $process = checkServerRunning();
    say OUTPUT 'Server process was found running - being killed now' if $verbose && $process;
    `sudo kill $process` if $process;
    say OUTPUT 'No server process was found running' if $verbose && !$process;
    do {
        my $serverCmd = (defined $environment && $environment eq 'prod' ? 'hypnotoad' : 'morbo');
        `nohup $serverCmd $mojoScript > $serverCmd.out 2>&1 &`;
        sleep 3;
    } while (!checkServerRunning());
    say OUTPUT 'Server restarted' if $verbose;
}

# builds the DB from scratch
sub rebuild {
    say OUTPUT 'Preparing to rebuild DB' if $verbose;
    chdir "$root/Database/";
    my @text = `./install.py`;
    if ($verbose) {
        foreach my $line (@text) {
            print OUTPUT $line;
        }
    }
}

# runs the mojolicious tests
sub test {
    say OUTPUT 'Preparing to start web services\' tests' if $verbose;
    $log ? `$mojoScript test -v >> $root/$log 2>&1` : `$mojoScript test -v 1>&2`;
}

# rebuilds the entire web environment
sub flush {
    pull();
    rebuild();
    restart();
    test();
}
