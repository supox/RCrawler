class Diamond < ActiveRecord::Base
  self.per_page = 25  
  attr_accessor :sort_by, :asc

  def self.search(search)
    order = search[:sort_by].downcase rescue :created_at
    order = :created_at if order.to_sym == :default
    asc = (search[:asc]=='1' ? :asc : :desc) rescue :asc
    search_no_sort(search).order(order=>asc)
  end

  def self.find_with_number_of_results(search)
    search_no_sort(search).select(:number_of_results, :rap_percentage).first
  end

  def self.ranges 
    v=["Excellent","Very Good", "Good"]
    {size:size_range, color:color_range, clarity: clarity_range, flour:["None", "Faint", "Medium", "Strong"], cut:v.dup, polish:v.dup, sym:v.dup }
  end

  def self.price_list_ranges
    v="Excellent"
    {size:size_range, color:color_range, clarity: clarity_range, cut:v.dup, polish:v.dup, sym:v.dup, flour:"None"} 
  end

  def self.search_by_options
    ['default'] + ranges.keys + ['updated_at', 'number_of_results', 'rap_percentage']
  end

  def percentage_with_offset
    (self.rap_percentage - Diamond.percentage_offset) if self.rap_percentage and valid_to_show?
  end

  def number_of_results_to_display
    return self.number_of_results if valid_to_show?
    0
  end

  def self.percentage_offset
    begin
      Setting.price_list[:extra_discount] || 0
    rescue
      0
    end
  end

  def price_offset
    nil
  end

  def valid_to_show?
    (self.number_of_results || 0) >= min_number_of_results_to_display
  end

  def self.dedupe
    # find all models and group them on keys which should be common
    grouped = all.group_by{|model| [model.size,model.color,model.cut,model.polish, model.clarity, model.flour, model.sym] }
    grouped.values.each do |duplicates|
      # the first one we want to keep right?
      first_one = duplicates.shift # or pop for last one
      # if there are any more left, they are duplicates
      # so delete all of them
      duplicates.each{|double| double.destroy} # duplicates can now be destroyed
    end
  end

  def self.ordered_by_last_update
    max_update_days_time = 90
    unscoped.where(Setting.crawling_ranges).where('updated_at < ?', 0.days.ago).where('updated_at > ?', max_update_days_time.days.ago).order(:updated_at)
  end

  private

  def min_number_of_results_to_display
    begin
      Setting.price_list[:min_number_of_results_to_display] || 50
    rescue
      50
    end
  end

  def self.search_no_sort(search)
    if search and search.respond_to? :map
      # white list
      search = Hash[search.map{ |k, v| [(k.to_sym if k.respond_to?('to_sym')), v] }]
      search_hash={}
      ranges.each do |k,v|
        search_hash[k] = search[k] if search[k] and search[k] != 'All' and k != :sort_by
      end
      return unscoped.where(search_hash)
    else
      return all
    end

  end

  def self.size_range
    0.3.step(3,0.1).collect {|f| f.round(1)}
  end

  def self.clarity_range
    ["IF", "VVS1", "VVS2", "VS1", "VS2", "SI1", "SI2", "I1"]
  end

  def self.color_range
    ("D".."M").to_a
  end

end

