class Period < ActiveRecord::Base
	belongs_to :region
	has_many :users, through: :regions
end
