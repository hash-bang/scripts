#!/usr/bin/perl
# POD {{{
=head1 NAME

ss - ScreenSession, a simple script to resume or create Screen sessions.

=head1 SYNOPSIS
	ss

=head1 BUGS

Quite probably.

=head1 AUTHOR

Matt Carter <m@ttcarter.com>

=cut
# }}} POD

$_ = `screen -ls`;

if (/^\s+([0-9]+)\./m) {
	$host = `hostname`;
	print "Resuming first found screen at PID $1\n";
	#`screen -X echo 'Incomming connection from $ENV{USER}\@$host'`;
	`screen -x $1`;
} else {
	print "No active screen found. Creating new session.\n";
	`screen`;
}
