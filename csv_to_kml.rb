#!/usr/bin/env ruby
require "csv"
require "rexml/document"
require "net/http"
require "json"
require "cgi"
require "logger"

# Initialize constants
CSV_PATH = ARGV[0] || "impianti.csv"
KML_PATH = ARGV[1] || "lista_impianti.kml"
NAME_FIELD = ARGV[2] || "Nome Cognome Cliente CAP"
ADDRESS_FIELD = ARGV[3] || "Indirizzo Cap Comune"
API_KEY = ENV["MAPS_API"]

# Set up logger
logger = Logger.new(STDOUT)

# Function to geocode address
def geocode(address, api_key)
  base_uri = "https://maps.googleapis.com/maps/api/geocode/json"
  uri = URI("#{base_uri}?address=#{CGI.escape(address)}&key=#{api_key}")
  response = Net::HTTP.get(uri)
  json = JSON.parse(response)
  logger.info "Response data: #{json["status"]}"
  if json["status"] == "OK"
    json["results"][0]["geometry"]["location"]
  else
    nil
  end
rescue StandardError => error
  logger.fatal "Failed to geocode address: #{error.message}"
  nil
end

# Load CSV file
begin
  logger.info "Loading csv file: #{CSV_PATH}"
  data = CSV.read(CSV_PATH, headers: true, encoding: "bom|utf-8")
  logger.info "Loaded csv file: #{CSV_PATH}"
rescue Errno::ENOENT => error
  logger.fatal "Failed to load csv file: #{error.message}"
  exit 1
end

# Create a new XML document
kml_doc = REXML::Document.new
kml_doc << REXML::XMLDecl.new

# Create a root element
root = kml_doc.add_element "kml", { "xmlns" => "http://www.opengis.net/kml/2.2" }

# Create a Document element
document = root.add_element "Document"

# Iterate over each row in the CSV file
data.each do |row|
  logger.info "Processing row: #{row}"
  #AVOID EOF
  if row[NAME_FIELD].nil? || row[ADDRESS_FIELD].nil?
    logger.info "No other name or address fields found! Parsing done"
    break
  end

  # Geocode the address
  location = geocode(row[ADDRESS_FIELD], API_KEY)
  next unless location

  # Create a Placemark for each row
  placemark = document.add_element "Placemark"

  # Add the name
  placemark.add_element("name").add_text row[NAME_FIELD]

  # Add the description with all the other data
  description = placemark.add_element "description"
  row.headers.each do |header|
    next if [NAME_FIELD, ADDRESS_FIELD].include?(header)
    description.add_text "#{header}: #{row[header.to_s]}\n"
  end

  # Add the Point with the coordinates
  point = placemark.add_element "Point"
  point.add_element("coordinates").add_text "#{location["lng"]},#{location["lat"]}"
end

# Write the KML file
begin
  logger.info "Writing KML file: #{KML_PATH}"
  File.open(KML_PATH, "w") { |f| f.write(kml_doc.to_s) }
  logger.info "Done! Thanks for using csv_to_kml!"
rescue StandardError => error
  logger.error "Failed to write KML file: #{error.message}"
  exit 1
end
