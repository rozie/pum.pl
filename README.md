pum.pl
========
Reading data from Uptime Monitor in Perl.

Usage
--------
Run the script, enjoy the output. All data are generated on ini file basis. All sections in ini file except [Global] section are treated as host data.
Config is read by default from ~/.uptime_monitor.ini file (yeah, hidden ini file).

Required modules
-------------------
* LWP::UserAgent
* Config::INI
* XML::Simple
 
[Global] section parameters
-----------------------------
* responseTimes [0|1] - should script retrive reponseTimes (unused right now)
* customUptimeRatio - days, separated with minus sign - for what periods get uptime ratio
* debug [0|1] - switches script in debug mode

[Host] section parameters
---------------------------
* apikey - API key (from Uptime Monitor)
* name - optional display name. Allows to overwrite friendlyName from Uptime Monitor, which is used by default.
