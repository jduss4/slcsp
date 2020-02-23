require "rake/testtask"
require_relative "test_helper.rb"

describe Calculator do
  it "initialized with instance variables" do
    calc = Calculator.new("slcsp.csv", "Silver")

    assert_equal "Silver", calc.plan_metal
    # make sure that csv file loaded correctly
    assert_equal 51, calc.lookup_zips.keys.length
    assert_equal "64148", calc.lookup_zips.keys.first
  end

  it "should list second cost rates for requested csv" do
    calc = Calculator.new("slcsp.csv", "Silver")

    rates = calc.list_second_cost_rates
    # remove the first row (since it is not a CSV object) is the header
    rates.shift
    assert_equal 51, rates.length

    # check a few specific rates looked up by hand
    assert calc.lookup_zips["54919"]

    assert calc.required_zipcodes.include?("54919")
    zipcodes_only = rates.map { |r| r.split(",").first }
    assert zipcodes_only.include?("54919")
  end

  it "should list second cost rates with zipcodes identical to input" do
    calc = Calculator.new("slcsp.csv", "Silver")

    rates = calc.list_second_cost_rates
    rates.shift
    input_zipcodes = calc.required_zipcodes
    output_zipcodes = rates.map { |r| r.split(",").first }
    assert_equal input_zipcodes, output_zipcodes
  end

  it "should have nil results for some zipcode second cost plans" do
    calc = Calculator.new("slcsp.csv", "Silver")

    rates = calc.list_second_cost_rates
    # checked by hand that this zipcode's region only has one
    # rate, therefore no second lowest rate and should be nil
    skip("TODO with 07184")
  end

  it "should have a different second cost rate for Silver and Gold plans" do
    silver = Calculator.new("slcsp.csv", "Silver").list_second_cost_rates
    gold = Calculator.new("slcsp.csv", "Gold").list_second_cost_rates

    refute_equal silver[1], gold[1]
  end

end