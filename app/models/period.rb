class Period < ActiveRecord::Base
  belongs_to :region

  def self.find_prices_for_region(region_id)
    price_instance_array = self.where(region_id: region_id)
    price_instance_array.map do |price_instance|
      price_instance.price
    end
  end

end
