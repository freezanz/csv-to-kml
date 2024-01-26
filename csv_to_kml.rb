require "csv"
require "rexml/document"
require "net/http"
require "json"
require "cgi"
require "debug"

# Function to geocode address
def geocode(address)
  api_key = ENV["MAPS_API"]
  base_uri = "https://maps.googleapis.com/maps/api/geocode/json"
  uri = URI("#{base_uri}?address=#{CGI.escape(address)}&key=#{api_key}")
  response = Net::HTTP.get(uri)
  json = JSON.parse(response)
  p "Response data: #{json["status"]}"
  if json["status"] == "OK"
    json["results"][0]["geometry"]["location"]
  else
    nil
  end
end

# Read the CSV file
csv_path = ARGV[0]
kml_path = ARGV[1]
#if path doesnt exist, return error
unless File.exist?(csv_path)
  puts "File #{csv_path} does not exist."
  exit 1
end

p "Loading csv file: #{csv_path}"
data = CSV.read(csv_path, headers: true, encoding: "bom|utf-8")
p "Loaded csv file: #{csv_path}"

# Create a new XML document
kml = REXML::Document.new
kml << REXML::XMLDecl.new

$name_field = ARGV[2] || "Nome Cognome Cliente CAP"
$address_field = ARGV[3] || "Indirizzo Cap Comune"

# Create a root element
root = kml.add_element "kml", { "xmlns" => "http://www.opengis.net/kml/2.2" }

# Create a Document element
document = root.add_element "Document"

# Iterate over each row in the CSV file
data.each do |row|
  break if row["#{$name_field}"].nil?
  # Geocode the address
  location = geocode(row["#{$address_field}"])
  if location
    # Create a Placemark for each row
    placemark = document.add_element "Placemark"

    # Add the name
    placemark.add_element("name").add_text row["#{$name_field}"]

    # Add the description with all the other data
    description = placemark.add_element "description"
    row.headers.each do |header|
      next if header == $name_field || header == $address_field
      description.add_text "#{header}: #{row[header.to_s]}\n"
    end

    # Add the Point with the coordinates
    point = placemark.add_element "Point"
    point.add_element("coordinates").add_text "#{location["lng"]},#{location["lat"]}"
  end
end

# Write the KML to a file
File.open(kml_path, "w") { |f| f.write(kml.to_s) }

p "Done! Thanks for using csv_to_kml!"
