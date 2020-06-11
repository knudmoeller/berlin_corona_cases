import re
import scrapy
import lxml.etree
import lxml.html

from coronaberlin.spiders import parse_german_float, extract_pr_date

class TrafficLightSpider(scrapy.Spider):
    name = "corona-traffic-light-scraper"
    start_urls = [
        "https://www.berlin.de/sen/gpg/service/presse/2020/?page_at_1_0=1",
    ]
    indicator_mapping = {
        "Reproduktionszahl": "basic_reproduction_number" ,
        "Inzidenz Neuinfektionen": "incidence_new_infections" ,
        "Anteil der": "icu_occupancy_rate"
    }
    indicators = ["basic_reproduction_number", "incidence_new_infections", "icu_occupancy_rate"]
    color_mapping = {
        "Grün": "green" ,
        "Gelb": "yellow" ,
        "Rot": "red"
    }


    # regex patterns
    corona_traffic_light_pattern = re.compile(r'Corona-Ampel: Die aktuellen Indikatoren')
    value_pattern = re.compile(r'(\d+,\d+)')

    def parse(self, response):
        press_release_page_links = response.css('.list-autoteaser .row-fluid .text a')
        traffic_light_links = \
            [page_link
             for page_link
             in press_release_page_links
             if TrafficLightSpider.corona_traffic_light_pattern.match(page_link.css('::text').get())]

        if traffic_light_links:
            yield from response.follow_all(traffic_light_links, self.parse_traffic_light_pr)

        pagination_links = response.css('li.pager-item-next a')
        if pagination_links:
            yield from response.follow_all(pagination_links, self.parse)

    def parse_traffic_light_pr(self, response):
        result = {
            'source': response.url ,
            'pr_date': extract_pr_date(response),
            'indicators': {}
        }

        value_lines = self.get_value_lines(response)

        zipped = zip(TrafficLightSpider.indicators, value_lines)
        for indicator, line in zipped:
            value_match = TrafficLightSpider.value_pattern.search(line)
            if value_match:
                parsed_value = parse_german_float(value_match.group(1))
                mapped_color = "unknown"
                for color_german in TrafficLightSpider.color_mapping:
                    if color_german in line:
                        mapped_color = TrafficLightSpider.color_mapping[color_german]    
                result['indicators'][indicator] = {
                    "value": parsed_value ,
                    "color": mapped_color
                }
            else:
                result['indicators'][indicator] = "Could not parse '{}'".format(line)


        # values = response.xpath('//p[contains(.,"→")]')
        
        # for item in values:
        #     unparsed_value = item.xpath('./text()[contains(.,"→")]').get()
        #     indicator_text = item.css('strong::text').get()
        #     for indicator_german in TrafficLightSpider.indicator_mapping.keys():
        #         if indicator_german in indicator_text:
        #             indicator = TrafficLightSpider.indicator_mapping[indicator_german]

        yield result

    def get_value_lines(self, response):
        root = lxml.html.fromstring(response.body)
        text = lxml.html.tostring(root, method="text", encoding=str)
        return [line.strip() for line in text.splitlines() if re.search(r'→', line)]

