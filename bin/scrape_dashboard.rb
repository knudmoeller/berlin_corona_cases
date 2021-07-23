require 'nokogiri'
require 'open-uri'
require 'logger'
require 'json'

DASHBOARD_URI = "https://www.berlin.de/corona/lagebericht/desktop/corona.html"

COLOR_MAPPING = {
    "#66C166" => "green" ,
    "#F6A942" => "yellow" ,
    "#F35C58" => "red"
}

DISTRICT_MAPPING = {
    "Mitte" => "lor_01",
    "Friedrichshain-Kreuzberg" => "lor_02",
    "Pankow" => "lor_03",
    "Charlottenburg-Wilmersdorf" => "lor_04",
    "Spandau" => "lor_05",
    "Steglitz-Zehlendorf" => "lor_06",
    "Tempelhof-Schöneberg" => "lor_07",
    "Neukölln" => "lor_08",
    "Treptow-Köpenick" => "lor_09",
    "Marzahn-Hellersdorf" => "lor_10",
    "Lichtenberg" => "lor_11",
    "Reinickendorf" => "lor_12",
}

LOGGER = Logger.new(STDOUT)

def extract_table(table)
    header = table.css("thead tr span").map { |span| span.text }
    data = table.css("tbody tr").map { |row| Hash[header.zip(row.css("span").map { |span| span.text })] }
end

def extract_district_data(doc)
    data = extract_table(doc.at_css("#kumulative-fallzahlen-und-inzidenzen-nach-bezirken table"))
    counts_per_district = {}
    data.each do |row|
        if (code = DISTRICT_MAPPING[row['Bezirk']])
            counts_per_district[code] = {
                :case_count => german_to_international_float(row['Fallzahl']).to_i ,
                :indicence => german_to_international_float(row['Fallzahl pro 100.000 Einwohner*']) ,
                :recovered => german_to_international_float(row['Genesen**']).to_i
            }
        end
    end
    counts_per_district.sort.to_h
end

def extract_age_group_data(doc)
    data = extract_table(doc.at_css("#kumulative-fallzahlen-und-inzidenzen-nach-altersgruppen table"))
    counts_per_age_group = {}
    data.each do |row|
        next if row['Altersgruppe'].eql?('Summe')
        age_group = row['Altersgruppe']
        unless age_group.eql?("unbekannt")
            counts_per_age_group[age_group] = {
                :case_count => german_to_international_float(row['Fallzahl']).to_i ,
                :incidence => german_to_international_float(row['Fallzahl pro 100.000 Einwohner*'])
            }
        else
            counts_per_age_group['unknown'] = {
                :case_count => german_to_international_float(row['Fallzahl']).to_i ,
                :indidence => "n.a."
            }
        end
    end
    counts_per_age_group
end

def german_to_international_float(text)
    value = "unknown"
    value = text.strip().gsub(/\s+/,"").gsub(".","").gsub(",",".").to_f if text
    value
end

# scraping hell: I need to look at the style attribute of the element to
# determine the color of the traffic light.
def extract_color(css)
    css.split(";").each do |rule|
        parsed = rule.split(":")
        if parsed[0].eql?("background-color")
            code = parsed[1].strip()
            if (name = COLOR_MAPPING[code])
                return name
            end
        end
    end
    return "unknown"
end

if ARGV.count == 3
    case_number_in_path = ARGV[0]
    traffic_light_in_path = ARGV[1]
    temp_folder = ARGV[2]

    LOGGER.info("reading current case number file #{case_number_in_path} ...")
    current_case_numbers = JSON.parse(File.read(case_number_in_path))

    LOGGER.info("reading current traffic light file #{traffic_light_in_path} ...")
    current_traffic_light_data = JSON.parse(File.read(traffic_light_in_path))

    LOGGER.info("loading and parsing dashboard from #{DASHBOARD_URI} ...")
    doc = Nokogiri::HTML(URI.open(DASHBOARD_URI))

    LOGGER.info("getting publication date ...")
    header_text = doc.at_css(".toptitle.h1").text.strip
    if (date_match = header_text.match(/(\d{2}\.\d{2}\.\d{4})/))
        dashboard_date = Date.strptime(date_match[1], '%d.%m.%Y')
        if dashboard_date != Date.today
            LOGGER.error("data for today has not been published yet: #{dashboard_date} (dashboard) != #{Date.today} (today)")
            exit
        else
            LOGGER.info("publication date is #{dashboard_date.iso8601} ...")
        end
    else
        LOGGER.error("could not determine publication date")
        exit
    end

    LOGGER.info("extracting case number data ...")
    last_case_number_date = current_case_numbers.first['date']
    if last_case_number_date == Date.today.iso8601
        LOGGER.error("case number data for #{last_case_number_date} already extracted ...")
    else
        new_case_numbers = {
            :date => dashboard_date.iso8601 ,
            :source => DASHBOARD_URI ,
            :counts_per_district => extract_district_data(doc) ,
            :counts_per_age_group => extract_age_group_data(doc)
        }

        current_case_numbers.unshift(new_case_numbers)
    end
    File.open(File.join(temp_folder, "berlin_corona_cases.json"), "wb") do |file|
        file.puts JSON.pretty_generate(current_case_numbers)
    end

    LOGGER.info("extracting traffic light and vaccination data ...")
    last_traffic_light_date = current_traffic_light_data.first['pr_date']
    if last_traffic_light_date == Date.today.iso8601
        LOGGER.error("traffic light data for #{last_traffic_light_date} already extracted ...")
    else
        new_traffic_light = {
            :source => DASHBOARD_URI ,
            :pr_date => dashboard_date.iso8601 ,
            :indicators => {
                :basic_reproduction_number => {
                    :color => "",
                    :value => 0.0
                } ,
                :incidence_new_infections => {
                    :color => extract_color(doc.at_css("#neuinfektionen")['style']) ,
                    :value => german_to_international_float(doc.css("#neuinfektionen .inner .value").text())
                } ,
                :icu_occupancy_rate => {
                    :color => extract_color(doc.at_css("#its")['style']) ,
                    :value => german_to_international_float(doc.css("#its .inner .value").text().gsub("%",""))
                } ,
                :change_incidence => {
                    :color => extract_color(doc.at_css("#rel_7TI")['style']) ,
                    :value => german_to_international_float(doc.css("#rel_7TI .inner .value").text().gsub("%","")).to_i
                }
            } ,
            :vaccination => {
               :total_administered =>
                    doc.css("#box-Impfdosen .inner .value").text().gsub(" ","").to_i ,
               :percentage_one_dose =>
                    german_to_international_float(doc.css("#box-erstimpfung .inner .value").text().gsub("%","")) ,
                :percentage_two_doses =>
                    german_to_international_float(doc.css("#box-zweitimpfung .inner .value").text().gsub("%",""))
            }
        }

        current_traffic_light_data.unshift(new_traffic_light)
    end
    File.open(File.join(temp_folder, "berlin_corona_traffic_light.json"), "wb") do |file|
        file.puts JSON.pretty_generate(current_traffic_light_data)
    end

else
    puts "usage: ruby #{File.basename(__FILE__)} CASE_NUMBER_IN.json TRAFFIC_LIGHT_IN.json TEMP_FOLDER"
end

