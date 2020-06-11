# This package will contain the spiders of your Scrapy project
#
# Please refer to the documentation for information on how to create and manage
# your spiders.

import re

date_pattern = re.compile(r'(\d\d)\.(\d\d)\.(\d\d\d\d)')

def parse_german_float(number):
    return float(number.replace(',', '.'))

def remove_thousand_separator(number):
    return number.replace('.', '')

def extract_pr_date(response):
    pr_text = response.css('.pressnumber::text').get().strip()
    date_match = date_pattern.search(pr_text)
    if date_match:
        return "{}-{}-{}".format(date_match.group(3), date_match.group(2), date_match.group(1))
    else:
        return "unknown"
