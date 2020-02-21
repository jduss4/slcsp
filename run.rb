#!/usr/bin/env ruby

require_relative "lib/calculator.rb"

calculator = Calculator.new()
rates = calculator.list_slcsp_rates
puts rates