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

    @lookup_zips = load_zipcodes_from_csv
    @plan_metal = plan_metal
  end

  def list_second_cost_rates
    # regions will collect all relevant state codes (NE1)
    # and associated Region class instances
    @regions = {}

    # create AreaRates objects accessible by state+code
    @regions = map_area_to_zipcode(required_zipcodes)

    # go through the plans and add them to regions as appropriate
    add_plans_to_regions

    # merge region plans back into zipcode
    zip_rates = merge_region_into_zipcode

    output = [
      "zipcode,rate"
    ]
    @lookup_zips.each do |row|
      if zip_rates.key?(row["zipcode"])
        selected = zip_rates[row["zipcode"]]
        output << [ row["zipcode"], selected ].join(",")
      end
    end
    output
  end

  def required_zipcodes
    @lookup_zips.map { |s| s["zipcode"] }
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

  def map_area_to_zipcode(zips)
    codes = {}
    # we only need information on the specific zipcodes specified
    # for the slcsp lookup, so pick and choose
    CSV.foreach(@zips_path, headers: true) do |row|
      if zips.include?(row["zipcode"])
        code = row_to_region_code(row)
        region = Region.new(row, code, @plan_metal)
        codes[code] = region
      end
    end
    codes
  end

  # read in CSV of zipcodes as Ruby object
  def load_zipcodes_from_csv
    path = File.join(@data_dir, "slcsp.csv")
    CSV.read(path, headers: :first_row, encoding: "utf-8")
  end

  def merge_region_into_zipcode
    zip_rates = {}
    @regions.each do |code, area_rates|
      zip = area_rates.zipcode
      rate = area_rates.calculate_second_lowest
      # it's possible that a zipcode is in more than one rate area
      # in that case, the instructions say to leave the rate blank
      zip_rates[zip] = zip_rates.key?(zip) ? nil : rate
    end
    zip_rates
  end

  def row_to_region_code(row)
    "#{row["state"]}#{row["rate_area"]}"
  end

end