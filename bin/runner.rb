#runner file for solar pay
require 'highline'
require 'pry'

@cli = HighLine.new


def welcome
	@cli.say("Welcome to:")
	@cli.say("SOLAR PAY")
end

def start
	welcome
	get_user_data


end

def get_user_data
	user = User.new
	user.name = get_name

	zip = get_zipcode
	user.cost = get_cost(zip)
	state = get_state
	user.region = get_region(state)

	#use bills input and period data to calculate consumption
	bills = get_bills
	consumption = bills.collect do |key, value|
		user.region.translate_bill_to_consumption(value, key)
	end

	#add consumption data to user
	user.q1_consumption = consumption[0]
	user.q2_consumption = consumption[1]
	user.q3_consumption = consumption[2]
	user.q4_consumption = consumption[3]

	user.save

end

def get_name
	@cli.ask("What is your name?")
end

def get_zipcode
	@cli.ask("What is your zip code?") {|r| r.validate = /^\d{5}$/}
end

def get_cost(zip_code)
	cost = Cost.find_or_create_by(zip_code: zip_code)
	cost.get_avg_cost
	cost.save
	cost
end

def get_state
	@cli.ask("What state do you live in?") {|r| r.validate = /^\w{2}$/}
end

def get_region(state)
	Region.return_user_region(state)
end

def get_bills
	#strings used to ask user
	quarters = ["January through March 2018", "April through June 2018", "July through September 2018", "October through December 2017"]
	#store results in bills
	bills = {}
	#prompt user pt1
	@cli.say("Please enter your most recent quarterly electricity bills as integers")

	#prompt for each quarter
	quarters.each_with_index do |quarter, i|
		q =  quarter.split.last + "Q#{i+1}"
		bill = @cli.ask("What was your bill for #{quarter}?", Integer)
		bills[q] = bill
	end
	bills
end
