class Region

  attr_reader :code, :zipcode

  def initialize(row, code)
    @code = code
    @zipcode = row["zipcode"]
    @silver_plan_rates = []
  end

  def add_rate(plan)
    if plan["metal_level"] == "Silver"
      @silver_plan_rates << plan["rate"].to_f
    end
  end

  def calculate_slcsp
    # remove the lowest sorting rate and get the remaining minimum
    sorted = @silver_plan_rates.uniq.sort
    sorted.shift
    min = sorted.min
    format_rate(min)
  end

  protected

  def format_rate(num)
    sprintf('%.2f', num) if num
  end

end