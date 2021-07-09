#!/usr/bin/env perl

use strict;
use warnings;

use Cwd qw(getcwd);
use Filesys::Notify::Simple;

if ( $ENV{DISABLE_MT_WATCHER} ) {
    warn('mt-watcher container is disbled.');
    exit;
}

# wait for `make me` to complete
sleep(5);

my $mt_home = $ENV{MT_HOME} || getcwd();
$mt_home =~ s{/+$}{};    # remove trailing slash

my @files   = ( map( {"$mt_home/$_"} qw(addons extlib lib plugins) ), glob("$mt_home/*.cgi") );
my $watcher = Filesys::Notify::Simple->new( \@files );
while (1) {
    $watcher->wait(
        sub {
            my @paths = grep {

                # exclude files other than "*.cgi" at the top level
                $_ =~ m{$mt_home/(?:[^/]+\.cgi|.*?/)};
            } map { $_->{path} } @_;

            return unless @paths;

            print( join( "\n", @paths ) . "\n" );
            system('docker kill -s HUP mt_mt_1');

            # throttling
            sleep(1);
        }
    );
}
