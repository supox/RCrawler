class Adjustment < ActiveRecord::Base
  self.per_page = 50
  default_scope order('created_at ASC') 

  def self.create_adjustments
    ranges = Diamond.ranges
    ranges[:size].each do |size|
      ranges[:color].each do |color|
        ranges[:clarity].each do |clarity|
          find_or_create_by({size:size, color:color, clarity:clarity})
        end
      end

    end
    
  end
end
