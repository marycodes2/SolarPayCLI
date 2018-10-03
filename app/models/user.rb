class User < ActiveRecord::Base
	belongs_to :cost
	belongs_to :region
	has_many :periods, through: :regions
end
