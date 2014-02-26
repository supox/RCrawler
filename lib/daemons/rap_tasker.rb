
class RapTasker
  def initialize
    if Diamond.count == 0
      prepare_db
    end
  end
  
  def prepare_db
    values_hash = Diamond.ranges
    @values = product_hash(values_hash)
    @values.each do |v|
        Diamond.new(v).save!
    end
  end

  def next
    Diamond.unscoped.where(search_ranges).where('updated_at < ?', 0.days.ago).order(:updated_at).first
  end

  private
  def product_hash(hsh)
    attrs   = hsh.values
    keys    = hsh.keys
    product = attrs[0].product(*attrs[1..-1])
    product.map{ |p| Hash[keys.zip p] }
  end
  
  def search_ranges
    unless @search_ranges
      ranges = CRAWLER_CONFIG["ranges"]
      sizes = ranges["size"]["start"].step(ranges["size"]["end"],0.1).collect {|f| f.round(1)}
      @search_ranges = {"size" => sizes}
      %w{cut polish sym flour clarity}.each do |p|
        @search_ranges[p]=ranges[p]
      end
      @search_ranges["color"] = (ranges["color"]["start"]..ranges["color"]["end"]).to_a
    end
    @search_ranges
  end
end

