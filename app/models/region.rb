class Region < ActiveRecord::Base

	has_many :periods
	has_many :users

	attr_accessor :linear_model, :q1_2019, :q2_2019, :q3_2019, :q4_2019

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

	def create_years_array(start_year, end_year)
		arr = (start_year..end_year).to_a
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
		if y < 0
			y = y * -1
		else
			y
		end
	end

	def get_2019_price_per_kwh
		@q1_2019 = (self.find_prices_for_region[3] / 100)
		@q2_2019 = (self.find_prices_for_region[2] / 100)
		@q3_2019 = (self.find_prices_for_region[1] / 100)
		@q4_2019 = (self.find_prices_for_region[0] / 100)
	end

	def find_solar_break_even(cost_of_solar, q1_consumption, q2_consumption, q3_consumption, q4_consumption)
		get_2019_price_per_kwh
		cost_of_solar = cost_of_solar.to_i
		quarters = create_years_array(2019, 2119)
		total_cost = 0
		break_even_quarter = 0
		quarters.each do |quarter|
			if quarter.to_s.split('.')[1].to_i == 25
				total_cost += self.q2_2019 * q2_consumption
				break_even_quarter = quarter
				break if total_cost > cost_of_solar
			elsif quarter.to_s.split('.')[1].to_i == 5
				total_cost += self.q3_2019 * q3_consumption
				break_even_quarter = quarter
				break if total_cost > cost_of_solar
			elsif quarter.to_s.split('.')[1].to_i == 75
				total_cost += self.q4_2019 * q4_consumption
				break_even_quarter = quarter
				break if total_cost > cost_of_solar
			else
				total_cost += self.q1_2019 * q1_consumption
				break_even_quarter = quarter
				break if total_cost > cost_of_solar
			end
		end
		break_even_quarter
	end


	def return_revenue_by_year(cost_of_solar, year, q1_consumption, q2_consumption, q3_consumption, q4_consumption)
		get_2019_price_per_kwh
		cost_of_solar = cost_of_solar.to_i
		quarters = create_years_array(2019, year)
		total_cost = 0
		quarters.each do |quarter|
			if quarter.to_s.split('.')[1].to_i == 25
				total_cost += self.q2_2019 * q2_consumption
			elsif quarter.to_s.split('.')[1].to_i == 5
				total_cost += self.q3_2019 * q3_consumption
			elsif quarter.to_s.split('.')[1].to_i == 75
				total_cost += self.q4_2019 * q4_consumption
			else
				total_cost += self.q1_2019 * q1_consumption
			end
		end
		total_cost - cost_of_solar
	end
end
