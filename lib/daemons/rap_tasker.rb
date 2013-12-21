
class RapTasker
  def initialize
    if Diamond.count == 0
      prepare_db
    end
  end
  
  def prepare_db
    v=["Excellent","Very Good", "Good"]
    values_hash = {size: 0.3.step(1,0.1).to_a, clarity: ["VS1", "VVS2", "VVS1", "IF"], color:("D".."M").to_a, sym:v, cut:v, polish:v, flour:["None", "Very Slight"]}
    @values = product_hash(values_hash)
    @values.each do |v|
        Diamond.new(v).save!
    end
  end

  def next
    Diamond.where('updated_at < ?', 0.days.ago).order(:updated_at).first
  end

  private
  def product_hash(hsh)
    attrs   = hsh.values
    keys    = hsh.keys
    product = attrs[0].product(*attrs[1..-1])
    product.map{ |p| Hash[keys.zip p] }
  end
  
end

