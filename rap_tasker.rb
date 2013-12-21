require './rap_model'
class RapTasker
  def initialize
    v=["Excellent","Very Good", "Good"]
    values_hash = {size: 0.3.step(1,0.1).to_a, clarity: ["VS1", "VVS2", "VVS1", "IF"], color:("D".."M").to_a, sym:v, cut:v, polish:v, flour:["None", "Very Slight"]}
    @values = product_hash(values_hash)
    @index = 0
    @model = RapModel.new
    @model.connect
  end
  
  def get_next_task
    begin
        return nil if @index >= @values.length
        task = @values[@index]
        @index += 1
    end while @model.get_id_for task
    task
  end

  def tasks
    @values
  end
  private
  def product_hash(hsh)
    attrs   = hsh.values
    keys    = hsh.keys
    product = attrs[0].product(*attrs[1..-1])
    product.map{ |p| Hash[keys.zip p] }
  end
  
end
