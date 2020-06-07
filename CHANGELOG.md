# Changelog

## Development

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
