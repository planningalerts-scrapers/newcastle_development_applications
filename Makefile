.phony: build run clean

all: run

clean:
	docker-compose rm -f
	mv data.sqlite prev-data.sqlite || true

build: clean scraper.rb Gemfile Gemfile.lock
	docker image build -t newcastle_atdis_test_scraper .

run: build
	docker-compose run scraper
	docker cp newcastle_atdis_test_scraper_run_1:/app/data.sqlite .
