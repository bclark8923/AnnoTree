#!/usr/bin/env perl

package Build;

use Getopt::Long;
use Modern::Perl '2013';

# prints the help menu
sub usage {
    say "Usage: build.pl [options]";
    say "---REQUIRED---";
    say "\t-e, --environment (awsdev1, matt)";
    say "\t\tenvironment that the script is running in";
    say "\t-a, --action (pull, restart, rebuild, flush)";
    say "\t\tpull will grab the latest information from the git repo (-r is required for this)";
    say "\t\trestart will restart the development server";
    say "\t\trebuild will reinitialize the DB";
    say "\t\tflush will pull, rebuild, and restart (-r required for this)";
    say "--OPTIONAL--";
    say "\t-r, --repo";
    say "\t\tname of the remote git repository";
    say "\t-l, --log [file]";
    say "\t\tpath to the file to write to";
    say "\t-v, --verbose";
    say "\t\tinclude messages to STDOUT about what the script is doing";
    say "\t-h, --help";
    say "\t\tprints this message";
}

my $verbose;
my $environment;
my $action;
my $repo;
my $log;
my $help;

GetOptions(
    'verbose'           => \$verbose,
    'environment|e=s'   => \$environment,
    'action|a=s'        => \$action,
    'log|l=s'           => \$log,
    'repo|r=s'          => \$repo,
    'help|h'            => \$help
) or die("Error in the supplied arguments. Please see build.pl -h for more information.\n");

usage() and exit 0 if $help;
usage() and exit 0 unless ($environment && $action);
