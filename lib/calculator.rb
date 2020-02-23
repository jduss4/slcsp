#!/usr/bin/env ruby

require "csv"
require_relative "region.rb"

class Calculator

  attr_reader :lookup_zips, :plan_metal

  def initialize(lookup_csv, plan_metal)
    # path to directory containing input CSVs
    @data_dir = File.join(File.dirname(__FILE__), "..", "data")
    @plans_path = File.join(@data_dir, "plans.csv")
    @zips_path = File.join(@data_dir, "zips.csv")

    # returns a hash with the zipcodes as keys
    @lookup_zips = load_zipcodes_from_csv
    @plan_metal = plan_metal
  end

  def list_second_cost_rates
    # regions will collect all relevant state codes (NE1)
    # and associated Region class instances
    @regions = {}

    # create AreaRates objects accessible by state+code
    @regions = map_area_to_zipcode

    # go through the plans and add them to regions as appropriate
    add_plans_to_regions

    # for each zipcode, grab the relevant region and plan
    zip_rates = add_rate_to_zipcode_by_region

    output = [
      "zipcode,rate"
    ]
    @lookup_zips.each do |zipcode, info|
      output << [ zipcode, info["rate"] ].join(",")
    end
    output
  end

  def required_zipcodes
    @lookup_zips.keys
  end

  private

  def add_plans_to_regions
    # now we only need information about plans in those specific state regions
    CSV.foreach(@plans_path, headers: true) do |row|
      code = row_to_region_code(row)
      if @regions.key?(code)
        region = @regions[code]
        region.add_rate(row)
      end
    end
  end

  def add_rate_to_zipcode_by_region
    @lookup_zips.each do |zipcode, info|
      region = info["region"]
      rate = @regions[region].calculate_second_lowest
      info["rate"] = rate
    end
  end

  def map_area_to_zipcode
    codes = {}
    zips = required_zipcodes
    # we only need information on the specific zipcodes specified
    # for the slcsp lookup, so pick and choose
    CSV.foreach(@zips_path, headers: true) do |row|
      if zips.include?(row["zipcode"])
        code = row_to_region_code(row)
        # create a new region if there is not already one with this code
        if !codes.key?(code)
          region = Region.new(row, code, @plan_metal)
          codes[code] = region
        end
        # add the same code to the lookup_zips object
        @lookup_zips[row["zipcode"]]["region"] = code
      end
    end
    codes
  end

  # read in CSV of zipcodes as Ruby object
  def load_zipcodes_from_csv
    path = File.join(@data_dir, "slcsp.csv")
    csv = CSV.read(path, headers: :first_row, encoding: "utf-8")
    zip_object = {}
    # trusting that the CSV is requesting unique zipcodes
    csv.each do |row|
      zip_object[row["zipcode"]] = {}
    end
    zip_object
  end

  def row_to_region_code(row)
    "#{row["state"]}#{row["rate_area"]}"
  end

end