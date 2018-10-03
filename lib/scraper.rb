## a class to scrape quote data from https://www.energysage.com's solar calculator quote based on zip codes.
require 'nokogiri'
require 'watir'
require 'pry'


class Scraper
	attr_reader :avg_cost
	URL_BASE = "https://www.energysage.com/market/start/?zip_code="
	def initialize(zip_code)
		self.zip_code = zip_code
		page = get_page_from_zip(@zip)
		tips = get_tooltips_from_page(page)
		costs = get_costs_from_tooltips(tips)
		@avg_cost = get_avg_cost(costs)


	end

	def self.get_cost(zip)
		scrape = self.new(zip)
		Cost.new(zip, scrape.avg_cost)
	end

	def zip_code=(zip)
		if !/^\d{5}$/.match(zip)
			raise ArgumentError.new("zip must be 5 digits")
		else
			@zip = zip
		end
	end


	def get_page_from_zip(zip)
		#create browser using watir
		browser = Watir::Browser.new(:chrome, headless: true)
		#convert zip to url
		url = URL_BASE + zip
		#go to url
		browser.goto url
		sleep(2)
		#get html, post javascript loading
		doc = Nokogiri::HTML.parse(browser.html)
	end

	def get_tooltips_from_page(doc)
		table = doc.css("#quotes-table")
		#get each data on savings row
		rows = table.css(".row-savings")[0].children.css("td")

		tips = rows.collect do |column|
			column.children[1]["title"]


		end

		tips
	end

	def get_costs_from_tooltips(tips)
		tips.collect do |string|
			price = string.split[4].sub('$', '')
			price.sub!(",", "")
			price.to_i
		end
	end

	def get_avg_cost(costs)
		size = costs.length
		total = 0.0
		costs.each { |cost| total += cost }
		total / size
	end


end
