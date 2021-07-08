#!/usr/bin/env perl

use strict;
use warnings;

use Filesys::Notify::Simple;

if ( $ENV{DISABLE_MT_WATCHER} ) {
    warn('mt-watcher container is disbled.');
    exit;
}

# wait for `make me` to complete
sleep(5);

my @files   = ( qw(addons extlib lib plugins), glob('*.cgi') );
my $watcher = Filesys::Notify::Simple->new( \@files );
while (1) {
    $watcher->wait(
        sub {
            my @events = @_;
            print( join( "\n", map { $_->{path} } @events ) . "\n" );
            system('docker kill -s HUP mt_mt_1');

            # throttling
            sleep(1);
        }
    );
}
