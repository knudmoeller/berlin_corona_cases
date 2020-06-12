# Changelog

## Development

## 0.2.2

- To more case number PRs (2020-04-26 and 2020-04-11) and two traffic light PRs (2020-06-08 and 2020-05-31) had been missing because the patterns to match their titles were too restrictive. They are now included.

## 0.2.1

- There were two PRs that had fallen through the cracks because they were named differently (2020-05-24 and 2020-05-25). Those two have now been added.

## 0.2.0

- Add a second scraper for the Corona traffic light press releases.
- Add `pr_date` (date of press release) to case number data.
- Move some scraper helper methods up to module.
- Restructure make targets: there is now one for each scraper (`case-numbers` and `traffic-light`). Both are now triggered by `data`.

## 0.1.0

- Counts per age group have been added as a new key `counts_per_age_group` for each press release that includes them (all but the very first ones).

## 0.0.3

- Fix bug where case numbers with thousands separators resulted in wrong data.

## 0.0.2

- Instead of extracting the press release's date for specific day of Corona case numbers, we now extract the date when the data itself was released. This was mostly identical, but in some cases not.
- Instead of extracting just a date, we now extract a datetime (no timezone).
- Logo added to project.

## 0.0.1

- initial version
- contains only counts per district
