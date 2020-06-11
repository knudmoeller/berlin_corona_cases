all: data traffic-light README.md

data: data/target/berlin_corona_cases.json
traffic-light: data/target/berlin_corona_traffic_light.latest.json

data/target/berlin_corona_cases.json: data/temp/berlin_corona_cases_scraped.json data/manual/manually_extracted.json | data/target
	@echo "combining JSON files ($^) ..."
	@echo "writing to $@ ..."
	@jq -s '[.[][]] | sort_by(.date) | reverse' $^ > $@

data/target/berlin_corona_traffic_light.json: data/temp/berlin_corona_traffic_light.json | data/target
	@echo "sorting and formatting $< ..."
	@echo "writing to $@ ..."
	@jq ". | sort_by(.pr_date) | reverse" $< > $@

data/target/berlin_corona_traffic_light.latest.json: data/target/berlin_corona_traffic_light.json
	@echo "extracting latest set of traffic light indicators from $< ..."
	@echo "writing to $@ ..."
	@jq ".[0]" $< > $@

.PHONY: data/temp/berlin_corona_cases_scraped.json
data/temp/berlin_corona_cases_scraped.json: | data/temp
	@echo "scraping corona case numbers from berlin.de ..."
	@echo "writing to $@ ..."
	@rm -f $@
	@scrapy crawl berlin-corona-scraper -o $@

.PHONY: data/temp/berlin_corona_traffic_light.json
data/temp/berlin_corona_traffic_light.json: | data/temp
	@echo "scraping corona traffic light numbers from berlin.de ..."
	@echo "writing to $@ ..."
	@rm -f $@
	@scrapy crawl corona-traffic-light-scraper -o $@

.PHONY: README.md
README.md: data/temp/date.txt
	@echo "update README.md with current date"
	@sed '$$ d' README.md > _README.md
	@cat _README.md $< > README.md
	@rm _README.md

.PHONY: data/temp/date.txt
data/temp/date.txt: | data/temp
	@echo "write current date ..."
	@date "+Last changed: %Y-%m-%d" > $@

clean: clean-temp clean-target

clean-temp:
	@echo "deleting temp folder ..."
	@rm -rf data/temp

clean-target:
	@echo "deleting target folder ..."
	@rm -rf data/target

data/temp:
	@echo "creating temp directory ..."
	@mkdir -p data/temp

data/target:
	@echo "creating target directory ..."
	@mkdir -p data/target

