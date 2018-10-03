class Region < ActiveRecord::Base
  has_many :periods

  def prices
    self.periods.map do |period|
      period.price
    end
  end

  def periods

  end

  def prediction

  end

end
