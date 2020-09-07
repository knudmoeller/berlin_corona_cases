require 'nokogiri'
require 'open-uri'
require 'json'

COLOR_MAPPING = {
    "#66C166" => "green" ,
}

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
        :value => doc.css("#r-wert .inner .value").text().strip().gsub(",",".").to_f
    } ,
    :incidence_new_infections => {
        :color => extract_color(doc.at_css("#neuinfektionen")['style']) ,
        :value => doc.css("#neuinfektionen .inner .value").text().strip().gsub(",",".").to_f
    } ,    
    :icu_occupancy_rate => {
        :color => extract_color(doc.at_css("#its")['style']) ,
        :value => doc.css("#its .inner .value").text().strip().gsub(",",".").gsub("%","").to_f
    }
}

puts JSON.pretty_generate(indicators)
