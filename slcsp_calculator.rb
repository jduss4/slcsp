#!/usr/bin/env ruby

require "csv"

# for each zipcode
#   build state region lookup code
# go through plans and ignore non-silvers
# match state region against plans
#   get second highest plan or empty
# build response and output

# path to directory containing input CSVs
data_dir = File.join(File.dirname(__FILE__), "data")
plans_path = File.join(data_dir, "plans.csv")
slcsp_path = File.join(data_dir, "slcsp.csv")
zips_path = File.join(data_dir, "zips.csv")

# read in slcsp file as csv object
slcsp = CSV.read(slcsp_path, headers: true, encoding: "utf-8")

required_zips = slcsp.map { |s| s["zipcode"] }

zip_to_code = {}

# we only need information on the specific zipcodes specified
# for the slcsp lookup, so pick and choose
CSV.foreach(zips_path, headers: true) do |row|
  if required_zips.include?(row["zipcode"])
    zip_to_code[row["zipcode"]] = "#{row["state"]}#{row["rate_area"]}"
  end
end

required_codes = zip_to_code.values

# now we only need information about plans in those specific state regions

plans = {}
CSV.foreach(plans_path, headers: true) do |row|
  state_area = "#{row["state"]}#{row["rate_area"]}"
  if required_codes.include?(state_area) && row["metal_level"] == "Silver"
    if plans.key?(state_area)
      plans[state_area] << row["rate"].to_f
    else
      plans[state_area] = Array(row["rate"].to_f)
    end
  end
end

puts "zipcode,rate"

plans.each do |area, rates|
  sorted = rates.uniq.sort
  # remove the lowest sorting rate and get the remaining minimum
  sorted.shift
  rate = sorted.min

  # find the zipcode using this area code
  zip = zip_to_code.key(area)
  puts "#{zip},#{rate}"
end
