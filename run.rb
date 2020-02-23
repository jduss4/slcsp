#!/usr/bin/env ruby

require_relative "lib/calculator.rb"

calculator = Calculator.new("slcsp.csv", "Silver")
rates = calculator.list_second_cost_rates
puts rates