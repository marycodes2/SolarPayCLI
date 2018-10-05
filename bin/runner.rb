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
	@cli.say(HighLine.color(solar_pay, :yellow))
end

def start
	welcome
	# user = get_user_data
	user = User.find(12)
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
	@cli.ask("Enter your 2 letter state abbreviation. Ex: MD for Maryland" ) {|r| r.validate = /^\w{2}$/}
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
	@cli.say("Please enter your average monthly electricity bill as integers")

	#prompt for each quarter
	quarters.each_with_index do |quarter, i|
		q =  quarter.split.last + "Q#{i+1}"
		bill = @cli.ask("What was your average mongthly bill during #{quarter}?", Integer)
		bills[q] = bill * 100 #convert to cents
	end
	bills
end

def menu(user)
	@cli.say("Hi #{user.name}, please choose a command:")
	loop = true

	while loop
		@cli.say "\n\n"
		@cli.choose do |menu|
			menu.index_color  = :blue
			menu.shell = true
			menu.choice("Get average cost to install solar panels in your zip code") {display_avg_cost(user)}
			menu.choice("Get your yearly power consumption") {display_consumption(user)}
			menu.choice("Get the year your solar panels pay themselves off") {display_breakpoint(user)}
			menu.choice("Get revenue from your solar panels each decade") {display_revenue_each_decade(user)}
			menu.choice("Get revenue from your solar panels given a year") {display_revenue_from_year(user)}
			menu.choice("Exit Solar Pay \n") {loop = false}
		end
		sleep(5) if (loop)
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
	@cli.say("to install solar panels is: #{cost.avg_cost.round(3)} ")
end

def display_consumption(user)
	consumption = []
	consumption << user.q1_consumption
	consumption << user.q2_consumption
	consumption << user.q3_consumption
	consumption << user.q4_consumption

	total_consumption = consumption.inject(0.0) do |amount, total|
		total += amount
	end
	@cli.say("Based on your electricity bills, you consumed")
	@cli.say("#{total_consumption.round}Kw/H over the course of the last year")
end


def display_revenue_from_year(user)
	cost = user.cost.avg_cost
	year = @cli.ask("What year would you like to know the revenue of your panels?", Integer) { |r| r.validate = /^(2019|20[2-9][0-9]|210[0-9]|211[0-9])$/}
	q1, q2, q3, q4 = user.q1_consumption, user.q2_consumption, user.q3_consumption, user.q4_consumption

	revenue = user.region.return_revenue_by_year(cost, year, q1, q2, q3, q4).round(2)
	revenue = "$" + (revenue > 0 ? HighLine.color(revenue.to_s, :green) : HighLine.color(revenue.to_s, :red))

	@cli.say("In the year #{year}, you will have made " + revenue + " from your solar panels")

end

def display_revenue_each_decade(user)
	cost = user.cost.avg_cost
	years = [2019, 2029, 2039, 2049, 2059]
	years.each do |year|
		q1, q2, q3, q4 = user.q1_consumption, user.q2_consumption, user.q3_consumption, user.q4_consumption

		revenue = user.region.return_revenue_by_year(cost, year, q1, q2, q3, q4).round(2)
		revenue = "$" + (revenue > 0 ? HighLine.color(revenue.to_s, :green) : HighLine.color(revenue.to_s, :red))

		@cli.say("In the year #{year}, you will have made " + revenue +" from your solar panels")
	end
end

def display_breakpoint(user)
	cost = user.cost.avg_cost
	q1, q2, q3, q4 = user.q1_consumption, user.q2_consumption, user.q3_consumption, user.q4_consumption
	year = user.region.find_solar_break_even(cost, q1, q2, q3, q4)
	info = year.to_s.split(".")
	year = info[0]
	q = (("0." + info.last).to_f + 0.25)  * 4
	@cli.say("In Q#{q.to_i} of #{year}, your solar panels will pay themselves off!")
end
