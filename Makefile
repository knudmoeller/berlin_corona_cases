all: data README.md

data: clean case-numbers traffic-light

case-numbers: data/target/berlin_corona_cases.json
traffic-light: data/target/berlin_corona_traffic_light.latest.json

data/target/berlin_corona_cases.json: data/temp/berlin_corona_cases.json | data/target
	@echo "copying data from $< to $@ ..."
	@cp $< $@ || true

data/target/berlin_corona_traffic_light.json: data/temp/berlin_corona_traffic_light.json | data/target
	@echo "copying data from $< to $@ ..."
	@cp $< $@ || true

data/target/berlin_corona_traffic_light.latest.json: data/target/berlin_corona_traffic_light.json
	@echo "extracting latest set of traffic light indicators from $< ..."
	@echo "writing to $@ ..."
	@jq ".[0]" $< > $@

data/temp/berlin_corona_cases.json: parse-dashboard

data/temp/berlin_corona_traffic_light.json: parse-dashboard

parse-dashboard: | data/temp
	@echo "running corona dashboard parser ..."
	@ruby bin/scrape_dashboard.rb data/target/berlin_corona_cases.json data/target/berlin_corona_traffic_light.json data/temp

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

clean: 
	@echo "deleting temp folder ..."
	@rm -rf data/temp

data/temp:
	@echo "creating temp directory ..."
	@mkdir -p data/temp

data/target:
	@echo "creating target directory ..."
	@mkdir -p data/target

