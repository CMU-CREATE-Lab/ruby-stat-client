# ruby-stat-client
Simple Ruby client for reporting to stat.createlab.org.

# Example usage

```
require File.expand_path('../ruby-stat-client/stat', __FILE__)

STAT_SERVICE_NAME = '{Scraper Name}'
STAT_HOSTNAME = '{Server scraper is running on}'
STAT_SHORTNAME = '{scraper-name}'

stat = Stat.new

stat.set_service(STAT_SERVICE_NAME)

# Do other code...

# Ping stat that successful completion of script occurred.  Set downtime threshold for 15 min, but can be whatever.
stat.up(summary: "Script successfully completed.", host: STAT_HOSTNAME, shortname: STAT_SHORTNAME, valid_for_secs: 60 * 15)
```
