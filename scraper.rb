#!/usr/bin/env ruby
Bundler.require

url = "https://property.ncc.nsw.gov.au/T1PRTESTBAU/WebAppServices/ATDIS/atdis/1.0"

ATDISPlanningAlertsFeed.save(url, timezone="Sydney", {lodgement_date_start: "2018-01-01", lodgement_end_date: "2018-03-01"})
