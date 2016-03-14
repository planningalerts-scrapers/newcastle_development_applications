#!/usr/bin/env ruby
Bundler.require

url = "http://da.ballina.nsw.gov.au/atdis/1.0"

ATDISPlanningAlertsFeed.save(url)
