#runner file for solar pay
require 'highline'
require 'pry'

@cli = HighLine.new



def welcome
	solar_pay = " _______  _______  ___      _______  ______      _______  _______  __   __
|       ||       ||   |    |   _   ||    _ |    |       ||   _   ||  | |  |
|  _____||   _   ||   |    |  |_|  ||   | ||    |    _  ||  |_|  ||  |_|  |
| |_____ |  | |  ||   |    |       ||   |_||_   |   |_| ||       ||       |
|_____  ||  |_|  ||   |___ |       ||    __  |  |    ___||       ||_     _|
 _____| ||       ||       ||   _   ||   |  | |  |   |    |   _   |  |   |  
|_______||_______||_______||__| |__||___|  |_|  |___|    |__| |__|  |___|  
"
	@cli.say("Welcome to:")
	@cli.say(solar_pay)
end

def start
	welcome
	# user = get_user_data
	user = User.find(5)
	menu(user)

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
	user
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

def menu(user)
	@cli.say("Please choose a command:")
	loop = true

	while loop
		@cli.say "\n\n"
		@cli.choose do |menu|
			menu.shell = true
			menu.choice("Get average cost to install solar panels in your zip code") {display_avg_cost(user)}
			menu.choice("Get your yearly power consumption") {display_consumption(user)}
			menu.choice("Get revenue from your solar panels given a year")
			menu.choice("Get revenue from your solar panels each decade")
			menu.choice("Get the year your solar panels pay themselves off")
			menu.choice("Exit Solar Pay") {loop = false}
		end
	end
end


def display_choices
	@cli.say("Solar Pay offers the following commands")
	@cli.say("1: Get average cost to install solar panels in your zip code")
	@cli.say("2: Get your yearly power consumption")
	@cli.say("3: Get revenue from your solar panels given a year")
	@cli.say("4: Get revenue from your solar panels each decade")
	@cli.say("5: Get the year your solar panels pay themselves off")
	@cli.say("6: Exit Solar Pay")
end

def display_avg_cost(user)
	cost = user.cost
	@cli.say("For the zip code #{cost.zip_code} the average price" )
	@cli.say("to install solar panels is: #{cost.avg_cost} ")
end

def display_consumption(user)
	consumption = []
	consumption << user.q1_consumption
	consumption << user.q2_consumption
	consumption << user.q3_consumption
	consumption << user.q4_consumption

	total_consumption = consumption.each_with_object(0.0) do |amount, total|
		total += amount
	end


end
