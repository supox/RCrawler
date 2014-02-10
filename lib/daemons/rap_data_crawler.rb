require 'selenium-webdriver'
require 'nokogiri'

class RapDataCrawler

  def open
    @browser ||= get_browser
    @opened = login
  end

  def close
    begin
      logout
      quit
    rescue
    end
    puts 'Closed crawler.'	
  end

  def opened?
    @opened ||= false
  end

  def crawl diamond    
    until opened? do
      if not open
        puts "Could not log-in, sleeping for 1 minute and try again."
        sleep 1.minute
      end
    end
    @params = diamond
    fetch_row
  end

  private

  def get_browser
    if CRAWLER_CONFIG["start_xvsb"]
      puts 'Starting xvsb display adapter'
      system('Xvfb :1 -screen 5 1024x768x8 &')
      system('export DISPLAY=:1.5')
    end
  
    puts 'Starting browser...'
    get_chrome
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

  def login
    link = 'https://www.rapnet.com/login/loginpage.aspx'
    username = CRAWLER_CONFIG["rap"]["username"]
    password = CRAWLER_CONFIG["rap"]["password"]
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

    if @browser.current_url =~ /AlreadyLoggedIn/
      puts "Login failed. Reason : already logged-in from another location."
      return false
    end

    puts "Logged-in. Page url = #{@browser.current_url}, page title = #{@browser.title}"
    true
  end

  def fetch_row
    tries = 0
    begin
      search
      parse_result	
    rescue  => e
      tries += 1
      retry unless tries >= 3
      puts "Could not load data for #{@params} (#{tries}/3). Reason = #{e}. Page title = #{@browser.title}."
      false
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

    puts "Filling fields for #{@params.inspect}"
    # size
    from_size = @params[:size]
    to_size = @params[:size] + 0.09
    @browser.find_element(:name, from_element_name).send_keys from_size.to_s
    @browser.find_element(:name, to_element_name).send_keys to_size.to_s

    # select_value_of_element(:id, number_of_results_per_page_id, "50")
    select_value_of_element(:id, shape_select_id, "Round")
    @browser.find_element(:id, gia_checkbox_id).click

    dont_fill_to_fields = true
    # clarity
    select_value_of_element(:id, clarity_from_id, @params[:clarity])
    select_value_of_element(:id, clarity_to_id, @params[:clarity]) unless dont_fill_to_fields
    # color
    select_value_of_element(:id, color_from_id, @params[:color])
    select_value_of_element(:id, color_to_id, @params[:color]) unless dont_fill_to_fields
    # sym
    select_value_of_element(:id, sym_from_id, @params[:sym])
    select_value_of_element(:id, sym_to_id, @params[:sym]) unless dont_fill_to_fields
    # cut
    select_value_of_element(:id, cut_from_id, @params[:cut])
    select_value_of_element(:id, cut_to_id, @params[:cut]) unless dont_fill_to_fields
    # polish
    select_value_of_element(:id, polish_from_id, @params[:polish])
    select_value_of_element(:id, polish_to_id, @params[:polish]) unless dont_fill_to_fields
    # flour
    select_value_of_element(:id, flour_id, @params[:flour])

    @browser.find_element(:name, search_element_name).click
  end

  def parse_result
    puts "Parsing page."

    # parse current page
    data, number_of_results = parse_page(@browser.page_source)
    if data
      relevant_stone = find_relevant_stone data
      rap_percentage = /(-?\d+)%/.match(relevant_stone["%/Rap"])[1].to_i
    else
      rap_percentage = 0
      number_of_results = 0
    end
    @params.update!({number_of_results:number_of_results, rap_percentage: rap_percentage, shape:"Round"})
    # get_next_page
  end

  def parse_page(html)
    begin
      doc = Nokogiri::HTML(html)

      return nil if doc.at_css('div#ctl00_cphMainContent_SummaryResults1_divNoResults')

      number_of_results_content=doc.css('span#ctl00_cphMainContent_lblDiamondsCount').text
      number_of_results=/Found (\d+,?\d*)/.match(number_of_results_content)[1].gsub(',','').to_i

      table = doc.css('table#ctl00_cphMainContent_gvResults')
      rows = table.css('tr.RowStyle, tr.AlternatingRowStyle')
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
    rescue Exception => ex  
      puts "Failed parse page, message : #{ex.message}. Page url = '#{@browser.current_url}', page title = '#{@browser.title}'"
    end
  end

  def find_relevant_stone data
    data = data.keep_if {|row| /(-?\d+)%/.match(row["%/Rap"])}
    data[33] || data.last
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
    begin
      logout_element = @browser.find_element(:id, logout_id)
      logout_element.click
    rescue
    end
  end

  def quit
    puts 'Quiting...'
    @browser.quit if @browser
  end

  def select_value_of_element(element_type,element_tag,selected_value)
    @browser.find_element(:xpath,"//select[@#{element_type}='#{element_tag}']/option[text()='#{selected_value}']").click
  end	
end
