# Newcastle ATDIS scraper (test only)

* Server - Technology One
* Pagnation - Yes
* JSON - Yes - Yay....

We're using the ATDIS feed for this scraper.

The test environment only has data up to early 2018, so we need to
manually start a lodgement_start_date otherwise the scraper doesn't
see anything in the last 30 days and exits.

For simpler local testing, simply run `make` on a machine with docker
and docker-compose installed. A docker image which (roughly) matches
what morph.io will run in production will be created and executed.

If the scraper run was successful, the resulting `data.sqlite` will be
extracted from the container and left in the current directory. The
next time `make` is run, this will be moved to `prev-data.sqlite`

Enjoy
