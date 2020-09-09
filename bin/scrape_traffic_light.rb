require 'nokogiri'
require 'open-uri'
require 'json'

COLOR_MAPPING = {
    "#66C166" => "green" ,
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
                :case_count => row['Fallzahl'].to_i ,
                :indicence => german_to_international_float(row['Inzidenz*']) ,
                :recovered => row['Genesen**'].to_i
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
                :case_count => row['Fallzahl'].to_i ,
                :incidence => german_to_international_float(row['Inzidenz*'])
            }
        else
            counts_per_age_group['unknown'] = {
                :case_count => row['Fallzahl'].to_i ,
                :indidence => "n.a."
            }
        end
    end
    counts_per_age_group
end

def german_to_international_float(text)
    text.strip().gsub(".","").gsub(",",".").to_f
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

doc = Nokogiri::HTML(URI.open("https://www.berlin.de/corona/lagebericht/desktop/corona.html"))

indicators = {
    :basic_reproduction_number => {
        :color => extract_color(doc.at_css("#r-wert")['style']) ,
        :value => german_to_international_float(doc.css("#r-wert .inner .value").text())
    } ,
    :incidence_new_infections => {
        :color => extract_color(doc.at_css("#neuinfektionen")['style']) ,
        :value => german_to_international_float(doc.css("#neuinfektionen .inner .value").text())
    } ,    
    :icu_occupancy_rate => {
        :color => extract_color(doc.at_css("#its")['style']) ,
        :value => german_to_international_float(doc.css("#its .inner .value").text().gsub("%",""))
    }
}

case_numbers = {
    :date => Date.today.iso8601 ,
    :source => "https://www.berlin.de/corona/lagebericht/desktop/corona.html" ,
    :counts_per_district => extract_district_data(doc) ,
    :counts_per_age_group => extract_age_group_data(doc)
}

puts JSON.pretty_generate(indicators)

puts JSON.pretty_generate(case_numbers)
