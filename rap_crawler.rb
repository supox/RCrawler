#!/usr/bin/env ruby 
require 'rubygems'
require 'selenium-webdriver'
require 'nokogiri'
require './rap_model'
require './rap_tasker'

class RapCrawler
	def initialize
		puts 'Starting browser...'
		@browser = get_chrome
		@model = RapModel.new
		@model.connect
	end
  
	def get_firefox
		profile = Selenium::WebDriver::Firefox::Profile.new
		## Disable CSS
		profile['permissions.default.stylesheet']= 2
		## Disable images
		profile['permissions.default.image']= 2
		## Disable Flash
		profile['dom.ipc.plugins.enabled.libflashplayer.so']= 'false'
		Selenium::WebDriver.for :firefox, :profile => profile
	end

	def get_chrome
		profile = Selenium::WebDriver::Chrome::Profile.new
		profile['webkit.webprefs.loads_images_automatically'] = false
		Selenium::WebDriver.for :chrome, :switches => %w[--ignore-certificate-errors --disable-popup-blocking --disable-translate --no-displaying-insecure-content]#, :profile=> offimg_profile
	end
	
	def get_htmlunit
	  caps = Selenium::WebDriver::Remote::Capabilities.htmlunit(:javascript_enabled => true)
		Selenium::WebDriver.for :remote, :url => "http://localhost:4444/wd/hub", :desired_capabilities => caps
	end
	
	def crawl     
		login
		fetch_data
		logout
		quit
		puts 'Done.'	
	end
	
	def login
		link = 'https://www.rapnet.com/login/loginpage.aspx'
		username = '78276'
		password = 'sschnitzer1'
		user_element_name = 'ctl00$cphMainContent$Login1$UserName'
		password_element_name = 'ctl00$cphMainContent$Login1$Password'
		login_element_name = 'ctl00$cphMainContent$Login1$LoginButton'

		puts 'Navigating to login page...'
		@browser.navigate.to link
		
		puts "Title = #{@browser.title}"
		puts 'Filling-up the fields'
		user_element = @browser.find_element(:name, user_element_name)
		pass_element = @browser.find_element(:name, password_element_name)
		login_element = @browser.find_element(:name, login_element_name)

		user_element.send_keys username
		pass_element.send_keys password
		login_element.click
		
		puts "Title = #{@browser.title}"
	end
	
	def fetch_data
		@tasker = RapTasker.new
		while @params=@tasker.get_next_task
			fetch_row
		end    
	end
	
	def fetch_row
		tries = 0
		begin
			search
			parse_result	
		rescue  => e
			tries += 1
			retry unless tries >= 3
			puts "Could not load data for #{@params}. Reason = #{e}" 
		end
	end
  
	def search(search_link = 'http://www.rapnet.com/RapNet/Search/')
		from_element_name = 'ctl00$cphMainContent$txtSizeFrom'
		to_element_name = 'ctl00$cphMainContent$txtSizeTo'
		search_element_name = 'ctl00$cphMainContent$btnSearch'
		shape_select_id = 'ctl00_cphMainContent_lstShapes'
		color_from_id = 'ctl00_cphMainContent_drpColorFrom'
		color_to_id = 'ctl00_cphMainContent_drpColorTo'
		clarity_from_id = 'ctl00_cphMainContent_drpClarityFrom'
		clarity_to_id = 'ctl00_cphMainContent_drpClarityTo'
	polish_from_id='ctl00_cphMainContent_drpPolishFrom'
	polish_to_id='ctl00_cphMainContent_drpPolishTo'
	sym_from_id='ctl00_cphMainContent_drpSymmFrom'
	sym_to_id='ctl00_cphMainContent_drpSymmTo'
	cut_from_id='ctl00_cphMainContent_drpCutFrom'
	cut_to_id='ctl00_cphMainContent_drpCutTo'
	flour_id='ctl00_cphMainContent_lstFluorescenceIntensity'
		number_of_results_per_page_id = 'ctl00_cphMainContent_drpNumberOfResults'
		latest_listing_id = 'ctl00_cphMainContent_chkLatestListings'
		gia_checkbox_id = 'ctl00_cphMainContent_chklstGradingReport_0'
		
		puts 'Navigating to search page...'
		@browser.navigate.to search_link

		puts "Filling fields for #{@params}"
	# size
		from_size = @params[:size]
		to_size = @params[:size] + 0.09
		@browser.find_element(:name, from_element_name).send_keys from_size.to_s
		@browser.find_element(:name, to_element_name).send_keys to_size.to_s
		
		# select_value_of_element(:id, number_of_results_per_page_id, "50")
		select_value_of_element(:id, shape_select_id, "Round")
	@browser.find_element(:id, gia_checkbox_id).click
 
	# clarity
	select_value_of_element(:id, clarity_from_id, @params[:clarity])
	select_value_of_element(:id, clarity_to_id, @params[:clarity])
	# color
	select_value_of_element(:id, color_from_id, @params[:color])
	select_value_of_element(:id, color_to_id, @params[:color])
	# sym
	select_value_of_element(:id, sym_from_id, @params[:sym])
	select_value_of_element(:id, sym_to_id, @params[:sym])
	# cut
	select_value_of_element(:id, cut_from_id, @params[:cut])
	select_value_of_element(:id, cut_to_id, @params[:cut])
	# polish
	select_value_of_element(:id, polish_from_id, @params[:polish])
	select_value_of_element(:id, polish_to_id, @params[:polish])
	# flour
	select_value_of_element(:id, flour_id, @params[:flour])
	
	@browser.find_element(:name, search_element_name).click
	end
	
	def parse_result
		begin
	  puts "Parsing page."
			  
	  # parse current page
	  data, number_of_results = parse_page(@browser.page_source)
	  relevant_stone = (data[33] || data.last)
	  
	  rap_percentage = /(-?\d+)%/.match(relevant_stone["%/Rap"])[1].to_i
	  row = @params.merge({number_of_results:number_of_results, rap_percentage: rap_percentage, shape:"Round"})
	  @model.insert(row)
	  # get_next_page
		rescue Exception => e
			# probably could not find next button, continue
			puts e.message  
		end
	end
	
	def parse_page(html)
		begin
			doc = Nokogiri::HTML(html)

	  number_of_results_content=doc.css('span#ctl00_cphMainContent_lblDiamondsCount').text
	  number_of_results=/Found (\d+,?\d*)/.match(number_of_results_content)[1].gsub(',','').to_i

			table = doc.css('table#ctl00_cphMainContent_gvResults')
			rows = table.css('tr.RowStyle')
			headers = table.css('tr.MelbourneRegularSmallHeader.GridHeader>th').collect{|td| td.content.strip}
			rejected_values = headers.collect{|header| header.nil? || header =~ /Status/ || header.length <= 1 }
			headers.reject!.with_index{|_,i| rejected_values[i]}

			data = rows.collect do |row|
		d={}
			  row.css('>td').reject.with_index{|_,i| rejected_values[i]}.each.with_index do |td, index|
				d[headers[index]] = td.content.strip
			end
		d
			end
			return data, number_of_results
		rescue Exception => e  
			puts e.message
		end
	end
	
	def get_next_page
		# click next
		# next_element = @browser.find_element(:id,'ctl00_cphMainContent_lbtnNext')
		# @browser.execute_script("window.scrollTo(0, #{next_element.location.y});") # workaround for chrome
		# next_element.click
		
		# easier just to run script.
		@browser.execute_script("__doPostBack('ctl00$cphMainContent$lbtnNextTop','')")

		wait = Selenium::WebDriver::Wait.new(:timeout => 30) # seconds
		# Wait for the loading to show
		wait.until { @browser.find_element(:id => "ctl00_cphMainContent_udProgress").displayed? } 
		# Wait for the loading to disappear	
		wait.until { not @browser.find_element(:id => "ctl00_cphMainContent_udProgress").displayed? }
	end
	
	def logout
		logout_id = 'ctl00_Navigation2_lbtnLogOut'

		puts 'Logging out'
		logout_element = @browser.find_element(:id, logout_id)
		logout_element.click
	end
	
	def quit
		puts 'Quiting'
		@browser.quit
	end
	
	def select_value_of_element(element_type,element_tag,selected_value)
		@browser.find_element(:xpath,"//select[@#{element_type}='#{element_tag}']/option[text()='#{selected_value}']").click
	end	
end

# execute spider
crawler = RapCrawler.new
crawler.crawl
