pum.pl
========
This is tool for reading data from Uptime Robot (external free uptime montior service; account required) written in Perl.

Features
----------
* runs from cron - separates backend from output
* keys to API objects are hidden
* allows to hide (overwrite) hostnames/IPs/URLs
* simple static HTML as output - no JS support in browser required

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
* HTML [0|1] - generate HTML output or not
* bootstrap [0|1] - use http://getbootstrap.com/ or not

[Host] section parameters
---------------------------
* apikey - API key (from Uptime Robot)
* name - optional display name. Allows to overwrite friendlyName from Uptime Robot, which is used by default.

Typical usage
-------------------------
Enable HTML and bootstrap in config file (HTML = 1 in [Global] section), make script executable (chmod +x pum.pl), add script to cron, redirect output to location readable by HTTP server.

*/30 * * * * ~/pum.pl > /tmp/pum.html && /bin/mv /tmp/pum.html /var/www/pum.html

License
----------
GPL v2. See LICENSE file.
