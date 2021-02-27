# Changelog

## Development

- Add vaccination data to the traffic light file (thanks [@jaimergp](https://github.com/jaimergp)). Vaccination data has been included since 2021-02-15.

## 0.4.5

_(2021-01-17)_

- Update Nokogiri via dependabot.

## 0.4.4

_(2020-12-17)_

- Check out a specific version of bundler to prevent the _"can't find gem bundler (>= 0.a) with executable bundle"_ error.
- Extend the cron by one hour to catch unusually late publications.

## 0.4.3

_(2020-12-06)_

- Extract change in 7-day incidence as an additional traffic light indicator.
The change in the 7-day incidence (_"Veränderung der 
7-Tage-Inzidenz"_) was introduced as an additional metric to the dashboard on 2020-11-11.

## 0.4.2

_(2020-11-24)_

- Another bugfix to adjust to differences in the markup (space as thousands separator, changed column name for incidence column).

## 0.4.1

_(2020-11-24)_

- Small bugfix (add test for `nil`  to `german_to_international_float()`) to prevent crashes due to missing values.

## 0.4.0

_(2020-10-18)_

- The scraper now runs automatically every day with GitHub Actions, [as recommended](https://github.com/knudmoeller/berlin_corona_cases/issues/1#issuecomment-698192160) by [@jaimergp](https://github.com/jaimergp).
There is a really cool little blog post on Git scraping by [@simonw](https://github.com/simonw) at https://simonwillison.net/2020/Oct/9/git-scraping/.
- Add [documentation for the GitHub Actions workflow](https://github.com/knudmoeller/berlin_corona_cases#running-automatically-with-github-actions) to the README.
- Update changelog with dates for each release.

## 0.3.3

_(2020-09-30)_

- Add the color code for a red traffic light indicator. Had to wait for an indicator to actually turn red to see what the code is. Unfortunately, this happened today (2020-09-30).

## 0.3.2

_(2020-09-24)_

- Add a Nokogiri-based (we're doing Ruby now, [because reasons](https://github.com/knudmoeller/berlin_corona_cases#what-happened-to-the-old-scraper)) scraper to extract both the case numbers and the traffic light data from the new corona dashboard.
- Update Makefile.
- Remove all Scrapy-related code.
- Update README to reflect all this.

## 0.3.1

_(2020-09-01)_

- Remove some Scrapy-related make targets.

## 0.3.0

_(2020-08-31)_

- The Senatsverwaltung stopped publishing corona press releases, so the scraper doesn't work anymore. Instead, I will now try to convert the daily JOSN with case numbers and extract the traffic light indicators from the new dashboard at https://www.berlin.de/corona/lagebericht/desktop/corona.html. The press releases weren't great, but at least there was an official record with a history of corona data. Now, there is only the data for the current day, which is lost once new data is published.
- Initially, the conversion from the new sources is done only half-automatically (it's late...).

## 0.2.4

_(2020-07-22)_

- Add quick links to data files at the top of the README).
- Add conditions to deal with bad source data for data's date (yeah).

## 0.2.3

_(2020-07-13)_

- Enable the Scrapy venv from within the Makefile. This requires a `SCRAPY_HOME` environment variable to be set (see README).

## 0.2.2

_(2020-07-12)_

- Two more case number PRs (2020-04-26 and 2020-04-11) and two traffic light PRs (2020-06-08 and 2020-05-31) had been missing because the patterns to match their titles were too restrictive. They are now included.

## 0.2.1

_(2020-07-11)_

- There were two PRs that had fallen through the cracks because they were named differently (2020-05-24 and 2020-05-25). Those two have now been added.

## 0.2.0

_(2020-06-11)_

- Add a second scraper for the Corona traffic light press releases.
- Add `pr_date` (date of press release) to case number data.
- Move some scraper helper methods up to module.
- Restructure make targets: there is now one for each scraper (`case-numbers` and `traffic-light`). Both are now triggered by `data`.

## 0.1.0

_(2020-06-07)_

- Counts per age group have been added as a new key `counts_per_age_group` for each press release that includes them (all but the very first ones).

## 0.0.3

_(2020-06-07)_

- Fix bug where case numbers with thousands separators resulted in wrong data.

## 0.0.2

_(2020-06-07)_

- Instead of extracting the press release's date for specific day of Corona case numbers, we now extract the date when the data itself was released. This was mostly identical, but in some cases not.
- Instead of extracting just a date, we now extract a datetime (no timezone).
- Logo added to project.

## 0.0.1

_(2020-06-05)_

- initial version
- contains only counts per district
