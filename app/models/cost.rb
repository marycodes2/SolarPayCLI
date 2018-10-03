class Cost < ActiveRecord::Base
	#has_many :users

	def zip_code=(zip)
		if !/^\d{5}$/.match(zip)
			raise ArgumentError.new("zip must be 5 digits")
		else
			@zip = zip
		end
	end

	#cost = Cost.create
	#cost.update(zip_code: "20015", avg_cost: Scraper.new("20015").avg_cost)
end
