class Cost < ActiveRecord::Base
	has_many :users

	def zip_code=(zip)
		if !/^\d{5}$/.match(zip)
			raise ArgumentError.new("zip must be 5 digits")
		else
			super(zip)
		end
	end

	def get_avg_cost
		if !self.zip_code
			raise NoMethodError.new("#{self} must have a valid zip code")
		end
		avg_cost = Scraper.new(self.zip_code).avg_cost
		self.update(avg_cost: avg_cost)
		avg_cost
	end

	#cost = Cost.create
	#cost.update(zip_code: "20015", avg_cost: Scraper.new("20015").avg_cost)
end
