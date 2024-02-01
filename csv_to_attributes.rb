#!/usr/bin/env ruby
require "csv"
require "logger"
require "debug"

# Initialize constants
CSV_PATH = ARGV[0] || "impianti.csv"
EDITED_CSV_PATH = ARGV[1] || "output.csv"
MAIN_TECHNICIAN_FIELD = ARGV[2] || "Tecnico di riferimento"
logger = Logger.new(STDOUT)

logger.info "Constants initialized: #{CSV_PATH}, #{EDITED_CSV_PATH}, #{MAIN_TECHNICIAN_FIELD}"

couples = {
  "mattia" => "Mattia Marinari - Simone Macchi",
  "federico" => "Federico Bigicchi - Michele Alzetta",
  "leonardo" => "Leonardo Sereni - Antonio Aprea",
  "maicol" => "Maicol Orlandini - Davide Bacci",
  "michele" => "Michele Alzetta - Federico Bigicchi",
}

logger.info "Technicians couples hash created. #{couples}"

# Load CSV file
begin
  logger.info "Loading csv file: #{CSV_PATH}"
  data = CSV.read(CSV_PATH, headers: true, encoding: "bom|utf-8")
  logger.info "Loaded csv file: #{CSV_PATH}"
rescue Errno::ENOENT => error
  logger.fatal "Failed to load csv file: #{error.message}"
  exit 1
end

# Iterate over each row
data.each do |row|
  if row["Nome Cognome Cliente CAP "].nil?
    logger.info "reached EOF"
    break
  end
  if row[MAIN_TECHNICIAN_FIELD].nil?
    logger.warn "No technician found for #{row}"
    next
  end

  name = row[MAIN_TECHNICIAN_FIELD].downcase
  # Substitute name with couple
  couples.each do |key, value|
    if name.include?(key)
      row[MAIN_TECHNICIAN_FIELD] = value
      logger.info "Couples substituted: #{key} -> #{value}"
      break
    end
  end
end

#write the edited csv
begin
  CSV.open(EDITED_CSV_PATH, "w") do |csv|
    data.each do |row|
      csv << row
    end
    logger.info "Data written in '#{EDITED_CSV_PATH}'"
  end
rescue StandardError => error
  logger.fatal "Failed to write edited csv file: #{error.message}"
  exit 1
end
