# Newcastle ATDIS scraper

* Server - Technology One
* ATDIS feed. Very simple to scrape. Thank you Newcastle Council!
* JSON - Yes - Yay....

For simple local testing, simply run `make` on a machine with docker
and docker-compose installed. A docker image which (roughly) matches
what morph.io will run in production will be created and executed.

If the scraper run was successful, the resulting `data.sqlite` will be
extracted from the container and left in the current directory. The
next time `make` is run, this will be moved to `prev-data.sqlite`

Enjoy
