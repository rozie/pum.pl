#!/usr/bin/perl

# Script for generating output based on data from Uptime Monitor service.
# Author: Pawe� 'R�a' R�a�ski rozie[at]poczta(dot)onet(dot)pl
# Homepage: https://github.com/rozie/pum.pl
# License: GPL v2.

# Usage: run the script, enjoy the output.
# Required modules: LWP::UserAgent, Config::INI, XML::Simple
# All data are generated on ini file basis. All sections in ini file except [Global] section are treated as host data.
# [Global] section parameters:
# responseTimes [0|1] - should script retrive reponseTimes
# customUptimeRatio - days, separated with minus sign - for what periods get uptime ratio
# debug [0|1] - switches script in debug mode
#
# [Host] section parameters:
# apikey - API key (from Uptime Monitor)
# name - optional display name. Allows overwrite friendlyName from Uptime Monitor, which is used by default.

my $Version="pum.pl 0.1\n";

use warnings;
use strict;
use XML::Simple;
use LWP::UserAgent;
use Data::Dumper;
use Config::INI::Reader;
use autodie;

my $configIniFile="$ENV{HOME}/.uptime_monitor.ini";		# default config file

my %type=(
	1 => 'HTTP(s)',
	2 => 'Keyword',
	3 => 'Ping',
	4 => 'Port'
);
my %status=(
	0 => 'paused',
	1 => 'not checked yet',
	2 => 'up',
	8 => 'seems down',
	9 => 'down'
);

my $config_hash = Config::INI::Reader->read_file($configIniFile);

my $responseTimes=$config_hash->{Global}->{responseTimes}?$config_hash->{Global}->{responseTimes}:0;
my $customUptimeRatio=$config_hash->{Global}->{customUptimeRatio};
my $debug=$config_hash->{Global}->{debug}?$config_hash->{Global}->{debug}:0;

print Dumper($config_hash) if $debug;
print "$responseTimes\n" if $debug;
print "$customUptimeRatio\n" if $debug;

# print headers
print "Hostname\tStatus\tType\t";
map {print "$_\t"} split /\-/,$customUptimeRatio;
print "\n";

# print host data
foreach (keys %$config_hash){
	if (! /^Global$/){
		my $apiKey=$config_hash->{$_}->{apikey};

		print "host config - $_\n" if $debug;
		print "DEBUG $apiKey\n" if $debug;

		my $url    = "https://api.uptimerobot.com/getMonitors?apiKey=" . $apiKey . "&format=xml&customUptimeRatio=$customUptimeRatio&responseTimes=$responseTimes";
		my $ua = new LWP::UserAgent;
		my $response = $ua->get($url);
		die "couldn't fetch xml\n" unless $response && $response->is_success ;

		my $xmlString = $response->content; 
		my $ref = XMLin($xmlString);
		print Dumper($ref) if $debug;
		my $friendlyName=$config_hash->{$_}->{name}?$config_hash->{$_}->{name}:$ref->{monitor}->{friendlyname};

		print "$friendlyName\t";
		print "$status{$ref->{monitor}->{status}}\t";
		print "$type{$ref->{monitor}->{type}}\t";
		map {print "$_%\t"} split /\-/, $ref->{monitor}->{customuptimeratio};
		print "\n";
	}
}