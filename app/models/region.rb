class Region < ActiveRecord::Base
  has_many :periods
  has_many :users

  def self.return_user_region(state)
    state = state.to_s
    state = state.upcase
    region_1 = ['AK', 'HI']
    region_2 = ['IL', 'IN', 'MI', 'OH', 'WI']
    region_3 = ['AL', 'KY', 'MS', 'TN']
    region_4 = ['NJ', 'NY', 'PA']
    region_5 = ['AZ', 'CO', 'ID', 'MT', 'NM', 'NV', 'UT', 'WY']
    region_6 = ['CT', 'MA', 'ME', 'NH', 'RI', 'VT']
    region_7 = ['CA', 'OR', 'WA']
    region_8 = ['DC', 'DE', 'FL', 'GA', 'MD', 'NC', 'SC', 'VA', 'WV']
    region_9 = ['IA', 'KS', 'MN', 'MO', 'ND', 'NE', 'SD']
    region_10 = ['AR', 'LA', 'OK', 'TX']
    if state.length != 2
      puts "Please enter a two digit state abbreviation. Example: please enter MD for Maryland."
    elsif region_1.include?(state)
      Region.find(1)
    elsif region_2.include?(state)
      Region.find(2)
    elsif region_3.include?(state)
      Region.find(3)
    elsif region_4.include?(state)
      Region.find(4)
    elsif region_5.include?(state)
      Region.find(5)
    elsif region_6.include?(state)
      Region.find(6)
    elsif region_7.include?(state)
      Region.find(7)
    elsif region_8.include?(state)
      Region.find(8)
    elsif region_9.include?(state)
      Region.find(9)
    elsif region_10.include?(state)
      Region.find(10)
    else
      puts "Please enter a valid state abbreviation"
    end
  end

  def find_prices_for_region
    Period.find_prices_for_region(self.id)
  end

  def find_periods_for_region
    Period.find_periods_for_region(self.id)
  end

  def translate_bill_to_consumption(bill, period_name)
    price = self.periods.find_by(name: period_name).price
    consumption = bill / price
    consumption
  end

  def create_years_array
    arr = (1990..2019).to_a
    new_arr = []
    arr.each do |year|
      new_arr << year + 0.00
      new_arr << year + 0.25
      new_arr << year + 0.50
      new_arr << year + 0.75
    end
    new_arr
  end

  def find_slope_of_region_line(year)
    linear_model = SimpleLinearRegression.new(self)
    y = linear_model.y_intercept + (linear_model.slope * year)
    y
  end

  def find_solar_break_even(price_of_solar, q1_consumption, q2_consumption, q3_consumption, q4_consumption)
    
  end

end
