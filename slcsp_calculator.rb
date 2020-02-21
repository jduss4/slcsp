#!/usr/bin/env ruby

require "csv"
require_relative "region.rb"

def print_rates(zip_rates)
  puts "zipcode,rate"
  @slcsp.each do |row|
    if zip_rates.key?(row["zipcode"])
      selected = zip_rates[row["zipcode"]]
      puts [ row["zipcode"], selected ].join(",")
    end
  end
end

def row_to_region_code(row)
  "#{row["state"]}#{row["rate_area"]}"
end

def map_area_to_zipcode(zipcode_csv)
  codes = {}
  # we only need information on the specific zipcodes specified
  # for the slcsp lookup, so pick and choose
  CSV.foreach(zipcode_csv, headers: true) do |row|
    if @required_zips.include?(row["zipcode"])
      code = row_to_region_code(row)
      region = Region.new(row, code)
      codes[code] = region
    end
  end
  codes
end

def add_plans_to_regions(plans_csv)
  # now we only need information about plans in those specific state regions
  CSV.foreach(plans_csv, headers: true) do |row|
    code = row_to_region_code(row)
    if @regions.key?(code)
      region = @regions[code]
      region.add_rate(row)
    end
  end
end

def merge_region_into_zipcode
  zip_rates = {}
  @regions.each do |code, area_rates|
    # puts area_rates.calculate_slcsp
    zip = area_rates.zipcode
    rate = area_rates.calculate_slcsp
    # it's possible that a zipcode is in more than one rate area
    # in that case, the instructions say to leave the rate blank
    zip_rates[zip] = zip_rates.key?(zip) ? nil : rate
  end
  zip_rates
end

# path to directory containing input CSVs
data_dir = File.join(File.dirname(__FILE__), "data")
plans_path = File.join(data_dir, "plans.csv")
slcsp_path = File.join(data_dir, "slcsp.csv")
zips_path = File.join(data_dir, "zips.csv")

# read in entire slcsp file as csv object
@slcsp = CSV.read(slcsp_path, headers: true, encoding: "utf-8")
@required_zips = @slcsp.map { |s| s["zipcode"] }

# create AreaRates objects accessible by state+code
@regions = map_area_to_zipcode(zips_path)
# go through the plans and add them to regions as appropriate
add_plans_to_regions(plans_path)

# merge region plans back into zipcode
zip_rates = merge_region_into_zipcode
# puts zip_rates
print_rates(zip_rates)
