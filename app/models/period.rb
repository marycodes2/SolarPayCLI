class Period < ActiveRecord::Base
	belongs_to :region
	has_many :users, through: :regions

	def self.find_prices_for_region(region_id)
		price_instance_array = self.where(region_id: region_id)
		price_instance_array.map do |price_instance|
			price_instance.price
		end
	end

  def self.find_periods_for_region(region_id)
    periods_instance_array = self.where(region_id: region_id)
    periods_instance_array.map do |period_instance|
      period_instance.name
    end
  end

end
