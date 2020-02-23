#!/usr/bin/env ruby

class Region

  attr_reader :code, :zipcode

  def initialize(row, code, metal)
    @code = code
    @zipcode = row["zipcode"]
    @metal = metal
    @plan_rates = []
  end

  def add_rate(plan)
    if plan["metal_level"] == @metal
      @plan_rates << plan["rate"].to_f
    end
  end

  def calculate_second_lowest
    # remove the lowest sorting rate and get the remaining minimum
    sorted = @plan_rates.uniq.sort
    sorted.shift
    min = sorted.min
    format_rate(min)
  end

  private

  def format_rate(num)
    sprintf('%.2f', num) if num
  end

end