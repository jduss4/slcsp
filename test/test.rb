require "rake/testtask"
require_relative "test_helper.rb"

describe Calculator do
  it "initialized with instance variables" do
    calc = Calculator.new("slcsp.csv", "Silver")

    assert_equal "Silver", calc.plan_metal
    # make sure that csv file loaded correctly
    assert_equal 51, calc.lookup_zips.length
    assert_equal "64148", calc.lookup_zips[0]["zipcode"]
  end

  it "should list second cost rates for requested csv" do
    calc = Calculator.new("slcsp.csv", "Silver")

    rates = calc.list_second_cost_rates
    # puts rates
    # assert_equal 51, rates.length

    # check a few specific rates looked up by hand
    assert calc.lookup_zips["54919"]

    assert calc.required_zipcodes.include?("54919")
    assert rates.map { |r| r[0] }.include?("54919")
  end
end