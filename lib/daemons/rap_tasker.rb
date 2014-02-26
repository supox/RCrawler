
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
    Diamond.unscoped.where(Setting.crawling_ranges).where('updated_at < ?', 0.days.ago).order(:updated_at).first
  end

  private
  def product_hash(hsh)
    attrs   = hsh.values
    keys    = hsh.keys
    product = attrs[0].product(*attrs[1..-1])
    product.map{ |p| Hash[keys.zip p] }
  end
  
end

