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
      system('killall Xvfb')
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
    begin
      open unless opened?
      search
      parse_result	
    rescue => e
      puts "Could not load data for #{@params}. Reason = #{e}. Sleeping for 20 seconds before trying again."
      sleep 20.second
      false
    end
  end

  def search(search_link = 'http://www.rapnet.com/RapNet/Search/')

    puts 'Navigating to search page...'
    @browser.navigate.to search_link
  
    cut_and_polish_options = {"Excellent"=>2,"Very Good"=>3, "Good"=>4}
    sym_options = {"Excellent"=>1,"Very Good"=>2, "Good"=>3}
    color_options = {}
    ('D'..'Z').each.with_index {|l,index| color_options[l]=index+1}
    clarity_options = {"FL"=>1, "IF"=>2, "VVS1"=>3, "VVS2"=>4, "VS1"=>5, "VS2"=>6, "SI1"=>7, "SI2"=>8, "SI3"=>9, "I1"=>10, "I2"=>11, "I3"=>12}
    flour_options = {"None"=>1,	"Very Slight"=>2}

    clarity = clarity_options[@params[:clarity]]
    color = color_options[@params[:color]]
    cut = cut_and_polish_options[@params[:cut]]
    polish = cut_and_polish_options[@params[:polish]]
    sym = sym_options[@params[:sym]]
    flour = flour_options[@params[:flour]]
    from_size = @params[:size]
    to_size = @params[:size] + 0.099
  
    puts "Filling fields for #{@params.inspect} at page #{@browser.current_url}"
    change_values_script = %{
      $('#ctl00_cphMainContent_lstShapes').val('1')    
      $('#ctl00_cphMainContent_drpColorTo').val('#{color}');
      $('#ctl00_cphMainContent_drpColorFrom').val('#{color}');
      $('#ctl00_cphMainContent_txtSizeFrom').val('#{from_size}');
      $('#ctl00_cphMainContent_txtSizeTo').val('#{to_size}');
      $('#ctl00_cphMainContent_drpClarityFrom').val('#{clarity}');
      $('#ctl00_cphMainContent_drpClarityTo').val('#{clarity}');
      $('#ctl00_cphMainContent_drpCutFrom').val('#{cut}');
      $('#ctl00_cphMainContent_drpCutTo').val('#{cut}');
      $('#ctl00_cphMainContent_drpPolishFrom').val('#{polish}');
      $('#ctl00_cphMainContent_drpPolishTo').val('#{polish}');
      $('#ctl00_cphMainContent_drpSymmFrom').val('#{sym}');
      $('#ctl00_cphMainContent_drpSymmTo').val('#{sym}');
      $('#ctl00_cphMainContent_lstFluorescenceIntensity').val('#{flour}');
      $('#ctl00_cphMainContent_chklstGradingReport_0').prop('checked', true);
      $('#ctl00_cphMainContent_btnSearch').click();
    }
    @browser.execute_script change_values_script
    # @browser.find_element(:name, 'ctl00$cphMainContent$btnSearch').click
    
  end

  def parse_result
    unless @browser.current_url =~ /Results.aspx/
      File.open("#{Dir.home}/bad_search.html", 'w') {|f| f.puts @browser.page_source} 
      raise "not in results page"
    end
    puts "Parsing page"

    # parse current page
    data, number_of_results = parse_page(@browser.page_source)
    if data
      relevant_stone = find_relevant_stone data
      rap_percentage = /(-?\d+)%/.match(relevant_stone["%/Rap"])[1].to_i rescue 0
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
