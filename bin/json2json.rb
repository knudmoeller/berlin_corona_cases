require 'date'
require 'json'
require 'pp'

district_mapping = {
    "Mitte" => "lor_01" ,
    "Friedrichshain-Kreuzberg" =>"lor_02" ,
    "Pankow" => "lor_03" ,
    "Charlottenburg-Wilmersdorf" => "lor_04" ,
    "Spandau" => "lor_05" ,
    "Steglitz-Zehlendorf" => "lor_06" ,
    "Tempelhof-Schöneberg" => "lor_07" ,
    "Neukölln" => "lor_08" ,
    "Neuköln" => "lor_08" ,
    "Treptow-Köpenick" => "lor_09" ,
    "Marzahn-Hellersdorf" => "lor_10" ,
    "Lichtenberg" => "lor_11" ,
    "Reinickendorf" => "lor_12" ,
}

new_case_data = {
    :date => Date.today.iso8601 ,
    :source => [
        "https://daten.berlin.de/datensaetze/covid-19-berlin-verteilung-den-bezirken" ,
        "https://daten.berlin.de/datensaetze/covid-19-fälle-im-land-berlin-verteilung-nach-altersgruppen"
    ] ,
    :comment => "The last Corona press release was published on 2020-08-30. After that, the data is extracted from the datasets with daily case numbers as shown in `source`." ,
    :counts_per_district => {} ,
    :counts_per_age_group => {} ,
}
source_path_districts = ARGV[0]
source_data_districts = JSON.parse(File.read(source_path_districts), :symbolize_names => true)
source_path_age_groups = ARGV[1]
source_data_age_groups = JSON.parse(File.read(source_path_age_groups), :symbolize_names => true)
target_data_path = ARGV[2]
target_data = JSON.parse(File.read(target_data_path))
    
source_data_districts[:index].each do |source_observation|
    district_name = source_observation[:bezirk]
    if (lor_code = district_mapping[district_name])
        target_observation = {
            :case_count => source_observation[:fallzahl].to_i  ,
            :incidence => source_observation[:inzidenz].to_f ,
            :recovered => source_observation[:genesen].to_i
        }
        new_case_data[:counts_per_district][lor_code.to_s] = target_observation
    end
    new_case_data[:counts_per_district] = new_case_data[:counts_per_district].sort.to_h
end

source_data_age_groups[:index].each do |source_observation|
    age_group = source_observation[:altersgruppe].strip
    age_group = "unknown" if age_group.eql?("unbekannt")
    unless age_group.eql?("Summe")
        target_observation = {
            :case_count => source_observation[:fallzahl].to_i ,
            :incidence => source_observation[:inzidenz].to_f ,
        }
        new_case_data[:counts_per_age_group][age_group] = target_observation
    end
end

target_data.unshift(new_case_data)
puts JSON.pretty_generate(target_data)