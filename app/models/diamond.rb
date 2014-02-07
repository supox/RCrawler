class Diamond < ActiveRecord::Base
  #acts_as_xlsx columns:[:size, :clarity, :color, :sym, :cut, :polish, :flour, :updated_at]

  self.per_page = 25  

  def self.search(search)
    if search and search.respond_to? :map
      # white list
      search = Hash[search.map{ |k, v| [(k.to_sym if k.respond_to?('to_sym')), v] }]
      search_hash={}
      ranges.each do |k,v|
        search_hash[k] = search[k] if search[k] and search[k] != 'All'
      end
      where(search_hash)
    else
      all
    end
  end

  def self.ranges 
    v=["Excellent","Very Good", "Good"]
    {size:0.3.step(1,0.1).collect {|f| f.round(1)}, clarity: ["VS1", "VVS2", "VVS1", "IF"], color:("D".."M").to_a, sym:v.dup, cut:v.dup, polish:v.dup, flour:["None", "Very Slight"]}
  end

  def self.price_list_ranges
    v="Excellent"
    {size:0.3.step(1,0.1).collect {|f| f.round(1)}, clarity: ["VS1", "VVS2", "VVS1", "IF"], color:("D".."M").to_a, sym:v.dup, cut:v.dup, polish:v.dup, flour:"None"} 
  end

end
