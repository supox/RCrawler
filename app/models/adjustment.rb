class Adjustment < ActiveRecord::Base
  self.per_page = 25
  default_scope { order('created_at ASC') }
  after_save :update_group, if: :in_groups?

  scope :groups, -> {where(:color => ["D", "G", "I", "K", "L"], clarity: ["IF", "VVS1", "VS1", "SI1", "I1"])}
  def self.groups_hash
    {
      color:{"D-F" => ("D".."F").to_a, "G-H" => ("G".."H").to_a, "I-J" => ["I", "J"], K: ["K"], "L-M" => ("L".."M").to_a},
      clarity:{"IF" => ["IF"], "VVS" => ["VVS1", "VVS2"], "VS" => ["VS1", "VS2"], "SI" => ["SI1", "SI2"], "I1" => ["I1"]}
    }
  end

  def color_group_name
    Adjustment.groups_hash[:color].each do |name,v|
      return name if v.include?(self.color)
    end
    return self.color
  end

  def clarity_group_name
    Adjustment.groups_hash[:clarity].each do |name,v|
      return name if v.include?(self.clarity)
    end
    return self.clarity
  end


  private
  def update_group
    color_group = Adjustment.groups_hash[:color].values.find{|c| c.include?(self.color)}
    clarity_group = Adjustment.groups_hash[:clarity].values.find{|c| c.include?(self.clarity)}
    group = Adjustment.where(color: color_group, clarity: clarity_group, size: self.size)

    attribs = attributes.select{|a| !['id','size','color','clarity'].include?(a)}
    group.each do |elm|
      next if self.id == elm.id
      elm.attributes = attribs 
      elm.save!
    end
  end

  def in_groups?
    return Adjustment.groups.where(id: self.id).exists?
  end

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

