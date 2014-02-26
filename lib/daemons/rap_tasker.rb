
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
    sizes = 0.3.step(1.5,0.1).collect {|f| f.round(1)}
    options = {size: sizes, cut:"Excellent", polish:"Excellent", sym:"Excellent" }

    Diamond.unscoped.where(options).where('updated_at < ?', 0.days.ago).order(:updated_at).first
  end

  private
  def product_hash(hsh)
    attrs   = hsh.values
    keys    = hsh.keys
    product = attrs[0].product(*attrs[1..-1])
    product.map{ |p| Hash[keys.zip p] }
  end
  
end

