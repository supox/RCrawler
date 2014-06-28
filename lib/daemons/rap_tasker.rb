
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
    entries = Diamond.ordered_by_last_update
    offset = rand([entries.count,100].min) # Choose randomily from the first 100 entries
    entries.first(offset:offset)
  end

  private
  def product_hash(hsh)
    attrs   = hsh.values
    keys    = hsh.keys
    product = attrs[0].product(*attrs[1..-1])
    product.map{ |p| Hash[keys.zip p] }
  end
  
end

