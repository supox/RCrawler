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
    if Setting.xvsb? and (not Rails.env.development?)
      puts 'Starting xvsb display adapter'
      system('killall Xvfb')
      ENV['DISPLAY']=':1.5'
      system('Xvfb :1 -screen 5 1024x768x8 &')
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
    username = Setting.rap[:username]
    password = Setting.rap[:password]
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
    begin
      open unless opened?
      search
      parse_result	
      Rails.logger.info "Updated data for #{@params}."
      sleep Setting.sleep_time.seconds if Setting.sleep_time > 0
    rescue => e
      if @browser.current_url =~ /LoginPage/
        @opened=false
      end
      puts "Could not load data for #{@params}. Reason = #{e}. Sleeping for 20 seconds before trying again."
      Rails.logger.info "Could not load data for #{@params}. Reason = #{e}"
      sleep 20.second
      false
    end
  end

  def search

    puts 'Navigating to search page...'
    
    # Direct link: (disabled)
    # search_link = 'http://www.rapnet.com/RapNet/Search/'
    # @browser.navigate.to search_link
    
    # By clicking on search element:
    @browser.find_element(:partial_link_text,"Buy Diamonds").click

    puts "Filling fields for #{@params.inspect} at page #{@browser.current_url}"

    if Setting.search_with_capy
      search_with_capy
    else
      search_with_js
    end
  end

  def search_with_js
    s = normalize_params
    change_values_script = %{
      $('#ctl00_cphMainContent_lstShapes').val('#{s.shape}')    
      $('#ctl00_cphMainContent_drpColorTo').val('#{s.color}');
      $('#ctl00_cphMainContent_drpColorFrom').val('#{s.color}');
      $('#ctl00_cphMainContent_txtSizeFrom').val('#{s.from_size}');
      $('#ctl00_cphMainContent_txtSizeTo').val('#{s.to_size}');
      $('#ctl00_cphMainContent_drpClarityFrom').val('#{s.clarity}');
      $('#ctl00_cphMainContent_drpClarityTo').val('#{s.clarity}');
      $('#ctl00_cphMainContent_drpCutFrom').val('#{s.cut}');
      $('#ctl00_cphMainContent_drpCutTo').val('#{s.cut}');
      $('#ctl00_cphMainContent_drpPolishFrom').val('#{s.polish}');
      $('#ctl00_cphMainContent_drpPolishTo').val('#{s.polish}');
      $('#ctl00_cphMainContent_drpSymmFrom').val('#{s.sym}');
      $('#ctl00_cphMainContent_drpSymmTo').val('#{s.sym}');
      $('#ctl00_cphMainContent_lstFluorescenceIntensity').val('#{s.flour}');
      $('#ctl00_cphMainContent_chklstGradingReport_0').prop('checked', true); // GIA Lab
      $('#ctl00_cphMainContent_btnSearch').click();
    }
    @browser.execute_script change_values_script
  end

  def normalize_params
    cut_and_polish_options = {"Excellent"=>2,"Very Good"=>3, "Good"=>4}
    sym_options = {"Excellent"=>1,"Very Good"=>2, "Good"=>3}
    color_options = {}
    ('D'..'Z').each.with_index {|l,index| color_options[l]=index+1}
    clarity_options = {"FL"=>1, "IF"=>2, "VVS1"=>3, "VVS2"=>4, "VS1"=>5, "VS2"=>6, "SI1"=>7, "SI2"=>8, "SI3"=>9, "I1"=>10, "I2"=>11, "I3"=>12}
    flour_options = {"None"=>1, "Very Slight"=>2, "Faint"=>3, "Medium"=>4, "Strong"=>5, "Very Strong"=>6}

    s.clarity = clarity_options[@params[:clarity]]
    s.color = color_options[@params[:color]]
    s.cut = cut_and_polish_options[@params[:cut]]
    s.polish = cut_and_polish_options[@params[:polish]]
    s.sym = sym_options[@params[:sym]]
    s.flour = flour_options[@params[:flour]]
    s.from_size = @params[:size]
    s.to_size = @params[:size] + 0.09
    s.shape = 1 # Round
    s
  end

  def search_with_capy
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
    unless @browser.current_url =~ /Results.aspx/
      File.open("#{Dir.home}/bad_search.html", 'w') {|f| f.puts @browser.page_source} 
      raise "not in results page"
    end

    # parse current page
    data, number_of_results = parse_page(@browser.page_source)
    if data
      relevant_stone = find_relevant_stone data
      rap_percentage = /(-?\d+)%/.match(relevant_stone["%/Rap"])[1].to_i rescue 0
    else
      rap_percentage = 0
      number_of_results = 0
    end

    puts "Parsed page, number of results = #{number_of_results}, %Rap = #{rap_percentage}"

    @params.update!({number_of_results:number_of_results, rap_percentage: rap_percentage, shape:"Round", updated_at:Time.now})
    # get_next_page
  end

  def parse_page(html)
    begin
      doc = Nokogiri::HTML(html)
      
      if doc.at_css('div#ctl00_cphMainContent_SummaryResults1_divNoResults')
        puts 'No results.'
        return nil
      end

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
      if @browser.title =~ /login/i
        @opened = false
        raise "login required."
      else
        raise ex
      end
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
      @opened = false
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
