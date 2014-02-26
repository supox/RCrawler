class Setting < ActiveRecord::Base
  def self.rap
    {username:s.rap_username, password:s.rap_password}
  end

  def self.price_list
    {
      extra_discount:s.price_list_extra_discount,
      min_number_of_results_to_display: s.price_list_min_number_of_results_to_display
    }
  end

  def self.xvsb?
    s.start_xvfb
  end

  def self.ranges
    {
      size:{start:s.ranges_size_start, end:s.ranges_size_end},
      cut:s.ranges_cut,
      polish:s.ranges_polish,
      sym:s.ranges_sym,
      clarity:s.ranges_clarity,
      color:{start:s.ranges_color_start, end:s.ranges_color_end},
      flour:s.ranges_flour
    }
  end

  def self.s
    @@s ||= first
  end

  def self.reload_settings
    @@s=nil
    self
  end

  def self.crawling_ranges
    ranges = self.reload_settings.ranges

    sizes = ranges[:size][:start].step(ranges[:size][:end],0.1).collect {|f| f.round(1)}
    search_ranges = {"size" => sizes}
    %w{cut polish sym flour clarity}.each do |p|
      search_ranges[p]=ranges[p.to_sym]
    end
    search_ranges["color"] = (ranges[:color][:start]..ranges[:color][:end]).to_a

    search_ranges
  end


end

