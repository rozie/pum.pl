#!/usr/bin/perl

# Script for generating output based on data from Uptime Robot service.
# Author: Pawe� 'R�a' R�a�ski rozie[at]poczta(dot)onet(dot)pl
# Homepage: https://github.com/rozie/pum.pl
# License: GPL v2.

# Usage: run the script, enjoy the output. See README for details.
# Required modules: LWP::UserAgent, Config::INI, XML::Simple

my $Version="pum.pl 0.2\n";

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
my $use_html=$config_hash->{Global}->{HTML}?$config_hash->{Global}->{HTML}:0;
my $use_bootstrap=$config_hash->{Global}->{bootstrap}?$config_hash->{Global}->{bootstrap}:0;

# get current date and format it
my ($sec ,$min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
$mon++;
$year+=1900;
$mon = sprintf ("%02d", $mon);
$mday = sprintf ("%02d", $mday);
$sec = sprintf ("%02d", $sec);
$min = sprintf ("%02d", $min);
$hour = sprintf ("%02d", $hour);

print Dumper($config_hash) if $debug;
print "$responseTimes\n" if $debug;
print "$customUptimeRatio\n" if $debug;

# print headers
if ($use_html){
    if ($use_bootstrap){
        print <<EOF;
<!DOCTYPE html>
<html lang="pl">
<head>
<title>Perl Uptime Monitor</title>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="refresh" content="300" />
<meta name='robots' content='noindex, nofollow, noarchive'/>
<meta name='content-language' content='pl'/>
<meta name="Description" content="Perl Uptime Monitor generated page"/>
<meta name='viewport' content="width=device-width, initial-scale=1"/>
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
<script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
</head>
<body>
EOF
	}
    else {
	print <<EOF;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pl" lang="pl">
<head>
<title>Perl Uptime Monitor</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="refresh" content="300" />
<meta name='robots' content='noindex, nofollow, noarchive'/>
<meta name='content-language' content='pl'/>
<meta name="Description" content="Perl Uptime Monitor generated page"/>
<meta name='viewport' content="width=device-width, initial-scale=1"/>
</head>
<body>
<center>
<table border="1">
EOF
}
        print '<div class="container">' if $use_bootstrap;
	print "<table class=\"table table-striped\"><thead><tr>" if $use_bootstrap;
        print "<th>Hostname</th><th>Status</th><th>Type</th>";
        map {print "<th>$_ d</th>"} split /\-/,$customUptimeRatio;
        print "<th>All time</th>";
	print "</thead><tbody>" if $use_bootstrap;
}

else {
	print "Hostname\tStatus\tType\t";
	map {print "$_ d\t"} split /\-/,$customUptimeRatio;
	print "all time\n";
}

# print host data
foreach (sort keys %$config_hash){
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
		if ($use_html){
                        print "<tr>";
                        print "<td>$friendlyName</td>";
                        print "<td>$status{$ref->{monitor}->{status}}</td>";
                        print "<td>$type{$ref->{monitor}->{type}}</td>";
                        map {print "<td>$_%</td>"} split /\-/, $ref->{monitor}->{customuptimeratio};
                        print "<td>$ref->{monitor}->{alltimeuptimeratio}%</td>";
                        print "</tr>";
		}
		else {
			print "$friendlyName\t";
			print "$status{$ref->{monitor}->{status}}\t";
			print "$type{$ref->{monitor}->{type}}\t";
			map {print "$_%\t"} split /\-/, $ref->{monitor}->{customuptimeratio};
			print "$ref->{monitor}->{alltimeuptimeratio}%";
			print "\n";
		}
	}
}

# HTML footer
if ($use_html){
	if ($use_bootstrap){
        	print "</tbody></table></div>";
		print "<footer class=\"container-fluid text-center\">";
		print "<p>Last update: $year.$mon.$mday $hour:$min:$sec</p>";
		print '<p>Generated by <a href="https://github.com/rozie/pum.pl">Perl Uptime Monitor</a></p>';
		print "</footer>";
		print "</body>";
		print "</html>";
	}
	else{
		print "</table>";
		print "<p>Last update: $year.$mon.$mday $hour:$min:$sec</p>";
		print '<p>Generated by <a href="https://github.com/rozie/pum.pl">Perl Uptime Monitor</a></p>';
		print "</center>";
		print "</body>";
		print "</html>";
	}
}
