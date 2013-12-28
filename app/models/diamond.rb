class Diamond < ActiveRecord::Base
  #acts_as_xlsx columns:[:size, :clarity, :color, :sym, :cut, :polish, :flour, :updated_at]

  self.per_page = 25  

  def self.search(search)
    if search
      # white list
      search_hash={}
      ranges.each do |k,v|
        search_hash[k] = search[k] if search[k] and search[k] != 'All'
      end
      p search
      p search_hash
      where(search_hash)
    else
      all
    end
  end

  def self.ranges 
    v=["Excellent","Very Good", "Good"]
    {size:0.3.step(1,0.1).collect {|f| f.round(1)}, clarity: ["VS1", "VVS2", "VVS1", "IF"], color:("D".."M").to_a, sym:v.dup, cut:v.dup, polish:v.dup, flour:["None", "Very Slight"]}
  end

end
