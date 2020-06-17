# Coronavirus Cases Scraper for Berlin

![logo for "Coronavirus Cases Scraper for Berlin" project](logo/corona_cases_berlin_small.png)

### Quick Links

* [Timeline of case numbers](data/target/berlin_corona_cases.json)
* [Timeline of traffic light indicators ("Corona Ampel")](data/target/berlin_corona_traffic_light.json)

This is a scraper for the (almost) daily press releases announcing the current Corona/COVID-19 case numbers for Berlin, as issued by the [Senatsverwaltung für Gesundheit, Pflege und Gleichstellung](https://www.berlin.de/sen/gpg/) (Senate Department for Health, Care and Equality).

A second scraper extracts the three "traffic light" indicators (basic reproduction number R, incidence of new infections per week, ICU occupancy rate).

The output of the scrapers are timelines of data extracted from the individual press releases.

## Output Data

### Corona Case Numbers

The timeline data generated by the case number scraper is a JSON file in [data/target/berlin_corona_cases.json](data/target/berlin_corona_cases.json), structured as follows:

```json
[
  {
    "source": "https://www.berlin.de/sen/gpg/service/presse/2020/pressemitteilung.941005.php",
    "pr_date": "2020-06-04",
    "date": "2020-06-04T12:00:00",
    "counts_per_district": {
      "lor_01": {
        "case_count": 998,
        "incidence": 258.7,
        "recovered": 943
      },
      "lor_02": {
        "case_count": 551,
        "incidence": 189.7,
        "recovered": 509
      },
      ...
      "lor_12": {
        "case_count": 523,
        "incidence": 196.3,
        "recovered": 476
      }
    } ,
    "counts_per_age_group": {
      "0-4": {
        "case_count": 106,
        "incidence": 55.9
      },
      "5-9": {
        "case_count": 95,
        "incidence": 55.3
      },
      ...
      "90+": {
        "case_count": 122,
        "incidence": 391.5
      },
      "unknown": {
        "case_count": 2,
        "incidence": "n.a."
      }
    }
  },
  {
    "source": "https://www.berlin.de/sen/gpg/service/presse/2020/pressemitteilung.940564.php",
    "pr_date": "2020-06-03",
    "date": "2020-06-03T12:00:00",
    "counts_per_district": {
      "lor_01": {
        "case_count": 994,
        "incidence": 257.7,
        "recovered": 942
      },
      "lor_02": {
        "case_count": 544,
        "incidence": 187.3,
        "recovered": 507
      },
      ...
      "lor_12": {
        "case_count": 522,
        "incidence": 195.9,
        "recovered": 473
      }
    },
    "counts_per_age_group": {
      "0-4": {
        "case_count": 103,
        "incidence": 54.3
      },
      "5-9": {
        "case_count": 93,
        "incidence": 54.2
      },
      ...
      "90+": {
        "case_count": 121,
        "incidence": 388.3
      },
      "unknown": {
        "case_count": 2,
        "incidence": "n.a."
      }
    }
  },
  ...
]
```

The structure of the data is a JSON array with objects for each scraped press release.
Each press release object specifies the `source` (the page that was scraped), , the `pr_date` (date when the press release was issued), the `date` (of the data), the `counts_per_district` and the `counts_per_age_group`.
`pr_date` and `date` are not always the same day.

#### Counts per District

The `counts_per_district` objects are structured with a key for each district, which in turn contain the actual numbers for the total `case_count`, `incidence` and number of `recovered` cases.

The district keys are their [LOR codes](data/manual/lor_district_codes.json) (see the dataset [Lebensweltlich orientierte Räume (LOR) in Berlin](https://daten.berlin.de/datensaetze/lebensweltlich-orientierte-räume-lor-berlin "The dataset 'Lebensweltlich orientierte Räume (LOR) in Berlin' on the Berlin Open Data Portal") for a complete definition of each LOR code):

```json
{
    "lor_01": "Mitte",
    "lor_02": "Friedrichshain-Kreuzberg",
    "lor_03": "Pankow",
    "lor_04": "Charlottenburg-Wilmersdorf",
    "lor_05": "Spandau",
    "lor_06": "Steglitz-Zehlendorf",
    "lor_07": "Tempelhof-Schöneberg",
    "lor_08": "Neukölln",
    "lor_09": "Treptow-Köpenick",
    "lor_10": "Marzahn-Hellersdorf",
    "lor_11": "Lichtenberg",
    "lor_12": "Reinickendorf"
}
```

#### Counts per Age Group

The `counts_per_age_group` objects are similarly structured, with a key for each age group, which in turn contain the `case_count` and `incidence` (no `recovered`).
The age group `80+` was split into `80-89` and `90+` beginning May 11th (2020-05-11).

There is a special `unknown` age group for which the `incidence` is always `n.a.`

#### Manually Extracted Data

Some of the earlier press releases had a slightly different format, or were only available as screen shots (true story), so the scraper did not work for them.
Rather than writing special code for extracting these one- or two-off cases, I manually extracted them and put them in [data/manual/manually_extracted.json](data/manual/manually_extracted.json).
When creating the complete timeline, this manually extracted data is merged with the scraped data.

### Corona Traffic Light Indicators

The data generated by the traffic light scraper is a JSON file located in [data/target/berlin_corona_traffic_light.json](data/target/berlin_corona_traffic_light.json). 
This data contains a timeline of traffic light press releases.
There is a second JSON file in [data/target/berlin_corona_traffic_light.latest.json](data/target/berlin_corona_traffic_light.latest.json) which always contains the latest traffic light press release.

The structure is as follows:

```json
[
  {
    "source": "https://www.berlin.de/sen/gpg/service/presse/2020/pressemitteilung.941003.php",
    "pr_date": "2020-06-04",
    "indicators": {
      "basic_reproduction_number": {
        "value": 0.85,
        "color": "green"
      },
      "incidence_new_infections": {
        "value": 5.1,
        "color": "green"
      },
      "icu_occupancy_rate": {
        "value": 3.6,
        "color": "green"
      }
    }
  },
  {
    "source": "https://www.berlin.de/sen/gpg/service/presse/2020/pressemitteilung.940565.php",
    "pr_date": "2020-06-03",
    "indicators": {
      "basic_reproduction_number": {
        "value": 1.32,
        "color": "red"
      },
      "incidence_new_infections": {
        "value": 5.1,
        "color": "green"
      },
      "icu_occupancy_rate": {
        "value": 3.4,
        "color": "green"
      }
    }
  },
  ...
]
```

The structure of the data is a JSON array with objects for each scraped press release.
Each press release object specifies the `source` (the page that was scraped), the `pr_date` (date when the press release was issued) and an `indicators` object.
`indicators` in turn cotains the three indicators `basic_reproduction_number` (basic reproduction number R), `incidence_new_infections` (incidence of new infections per 100,000 inhabitants per week) and `icu_occupancy_rate` (the ICU occupancy rate in %: which percentage of the available ICU capacity is currently being used).
Each indicator has a numeric `value` and a traffic light `color`-code (one of [`green`, `yellow`, `red`]).
For the exact meaning of color codes please refer to the press releases.

## Running the Scraper

I will try to update the data regularly, but if you want to run the scraper yourself (to improve it, or because I'm lagging behind the press releases), you can. Here is how:

### Requirements

* Python 3.5+ (required by Scrapy)
* the [Scrapy](https://scrapy.org) Web-scraping framework
* the [jq](https://stedolan.github.io/jq/) JSON processor (for merging the scraped with the manually extracted data).

### Installation

First, install the Scrapy framework.
To achieve this, follow the [installation guide in the Scrapy documentation](https://docs.scrapy.org/en/latest/intro/install.html).
Next, you need to define an environment variable `SCRAPY_HOME` which points to the folder where Scrapy is installed.
This environment variable is used in the Makefile to the virtual environment where scrapy is enabled.
E.g., I have added something like the following line to my `.bashrc`:

```shell
export SCRAPY_HOME=/home/knud/path/to/scrapy/
```

Once you have done this, you can clone this repository anywhere you like and run the desired make target (see below).

### Make Targets

There is a [Makefile](Makefile) that orchestrates the scraping. The targets should be easy to understand (each one has an `echo` statement that verbosely says what it does).

To create the complete timeline (scraped + manual data) for both scrapers, do this:

```
(scrapy) $ make data
scraping corona case numbers from berlin.de ...
writing to data/temp/berlin_corona_cases_scraped.json ...
2020-06-11 17:22:55 [scrapy.utils.log] INFO: Scrapy 2.0.0 started (bot: coronaberlin)

... lots of output from Scrapy ...

2020-06-11 17:22:58 [scrapy.core.engine] INFO: Spider closed (finished)
combining JSON files (data/temp/berlin_corona_cases_scraped.json data/manual/manually_extracted.json) ...
writing to data/target/berlin_corona_cases.json ...
scraping corona traffic light numbers from berlin.de ...
writing to data/temp/berlin_corona_traffic_light.json ...
2020-06-11 17:22:59 [scrapy.utils.log] INFO: Scrapy 2.0.0 started (bot: coronaberlin)

... lots of output from Scrapy ...

2020-06-11 17:23:01 [scrapy.core.engine] INFO: Spider closed (finished)
sorting and formatting data/temp/berlin_corona_traffic_light.json ...
writing to data/target/berlin_corona_traffic_light.json ...
extracting latest set of traffic light indicators from data/target/berlin_corona_traffic_light.json ...
writing to data/target/berlin_corona_traffic_light.latest.json
```

## Logo

- [virus](https://fontawesome.com/icons/virus) logo by [FontAwesome](https://fontawesome.com) under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## License

All software in this repository is published under the [MIT License](LICENSE).
All data in this repository (in particular the `.json` files) is published under [CC BY 3.0 DE](https://creativecommons.org/licenses/by/3.0/de/).

## Disclaimer

I do not make any claims that the data in [data/target/berlin_corona_cases.json](data/target/berlin_corona_cases.json) is correct!
If you find bugs in the code or in the data, please let me know by opening an issue [here](https://github.com/knudmoeller/berlin_corona_cases/issues).

---

2020, Knud Möller

Last changed: 2020-06-17
