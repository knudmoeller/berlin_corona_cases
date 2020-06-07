from collections import OrderedDict
import re
import scrapy

class CoronaSpider(scrapy.Spider):
    name = "berlin-corona-scraper"
    start_urls = [
        "https://www.berlin.de/sen/gpg/service/presse/2020/?page_at_1_0=1",
    ]

    district_mapping = {
        "Mitte": "lor_01" ,
        "Friedrichshain-Kreuzberg": "lor_02" ,
        "Pankow": "lor_03" ,
        "Charlottenburg-Wilmersdorf": "lor_04" ,
        "Spandau": "lor_05" ,
        "Steglitz-Zehlendorf": "lor_06" ,
        "Tempelhof-Schöneberg": "lor_07" ,
        "Neukölln": "lor_08" ,
        "Neuköln": "lor_08" ,
        "Treptow-Köpenick": "lor_09" ,
        "Marzahn-Hellersdorf": "lor_10" ,
        "Lichtenberg": "lor_11" ,
        "Reinickendorf": "lor_12" ,
    }

    # regex patterns
    corona_press_release_pattern = re.compile(r'Coronavirus: Derzeit \d+ bestätigte Fälle in Berlin')
    datetime_pattern = re.compile(r'(\d\d)\.(\d\d)\.(\d\d\d\d), (\d\d)\:(\d\d)')
    case_count_pattern = re.compile(r'((\d|\.)+)\s*(\(.+\))?')
    german_float_pattern = re.compile(r'')
    item_pattern = re.compile(r"\d+\. ein.+({}).+".format("|".join(district_mapping.keys())))

    def parse(self, response):
        press_release_page_links = response.css('.list-autoteaser .row-fluid .text a')
        corona_case_page_links = \
            [page_link \
            for page_link \
            in press_release_page_links \
            if CoronaSpider.corona_press_release_pattern.match(page_link.css('::text').get())]

        if corona_case_page_links:
            yield from response.follow_all(corona_case_page_links, self.parse_corona_pr)

        pagination_links = response.css('li.pager-item-next a')
        if pagination_links:
            yield from response.follow_all(pagination_links, self.parse)

    def parse_corona_pr(self, response):
        result = {
            'source': response.url
        }

        # get date
        date_texts = response.css('.html5-section.body h2::text')
        if date_texts:
            merged = '|'.join([date_text.get() for date_text in date_texts])
            date_match = CoronaSpider.datetime_pattern.search(merged)
            iso_date = "{}-{}-{}T{}:{}:00".format(date_match.group(3), date_match.group(2), date_match.group(1), date_match.group(4), date_match.group(5))
            result['date'] = iso_date

        list_pages = {
            'https://www.berlin.de/sen/gpg/service/presse/2020/pressemitteilung.904147.php': '2020-03-08T09:30:00' ,
            'https://www.berlin.de/sen/gpg/service/presse/2020/pressemitteilung.904264.php': '2020-03-09T09:30:00'
        }

        if response.url in list_pages.keys() :
            result['date'] = list_pages[response.url]
            result = self.parse_list(response, result)
        else:
            result = self.parse_table(response, result)

        if response.url == 'https://www.berlin.de/sen/gpg/service/presse/2020/pressemitteilung.904147.php':
            result['comment'] = "Only a date has been given in this press release, no time. The time given in the 'date'-field is a guess, based on the press release from 2020-03-09."

        yield result

    def parse_table(self, response, result):
        # get first table (Bezirke)
        tables = response.css('.table-responsive')
        if not tables:
            return None
        rows = tables[0].css('tr')
        per_district = {}
        for row in rows[1:-1]:
            cells = row.css('td::text')
            district = self.parse_district(cells[0].get().strip())
            case_count = int(self.parse_case_count(cells[1].get().strip()))
            incidence = self.parse_german_float(cells[2].get().strip())
            per_district[district] = {
                'case_count': case_count,
                'incidence': incidence,
            }
            if len(cells) > 3:
                recovered = self.parse_recovered(cells[3].get().strip())
                per_district[district]['recovered'] = recovered

        result['counts_per_district'] = OrderedDict(sorted(per_district.items()))

        return result

    def parse_list(self, response, result):
        per_district = {}
        for lor_key in CoronaSpider.district_mapping.values():
            per_district[lor_key] = { 'case_count': 0 }

        list_blob = response.css(".column-content .textile p:nth-of-type(3)::text")

        for item in list_blob:
            item = item.get().strip()
            item_match = CoronaSpider.item_pattern.match(item)
            if item_match:
                district = item_match.group(1)
                lor_key = CoronaSpider.district_mapping[district]
                per_district[lor_key]['case_count'] += 1

        result['counts_per_district'] = OrderedDict(sorted(per_district.items()))

        return result


    def parse_district(self, district):
        return CoronaSpider.district_mapping[district.strip()]

    def parse_case_count(self, case_count):
        count_match = CoronaSpider.case_count_pattern.match(case_count.strip())
        case_count = count_match.group(1)
        case_count = self.remove_thousand_separator(case_count)
        return case_count

    def parse_recovered(self, value):
        na_values = [ "n.a.", "n.a" ]
        if value in na_values:
            return "n.a."
        else:
            return int(value)

    def parse_german_float(self, number):
        return float(number.replace(',', '.'))

    def remove_thousand_separator(self, number):
        return number.replace('.','')
