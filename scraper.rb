#!/usr/bin/env ruby
Bundler.require

url = "https://property.ncc.nsw.gov.au/T1PRPROD/WebAppServices/ATDIS/atdis/1.0"

ATDISPlanningAlertsFeed.save(url, timezone="Sydney")
