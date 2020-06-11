# This package will contain the spiders of your Scrapy project
#
# Please refer to the documentation for information on how to create and manage
# your spiders.

def parse_german_float(number):
    return float(number.replace(',', '.'))

def remove_thousand_separator(number):
    return number.replace('.', '')
