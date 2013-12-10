require './rap_model'
class RapTasker
  def initialize
    @size = 0.3
  end
  def get_next_task
    return nil if @size > 1
    task = {size:@size, clarity:"VS1", color:"D", sym:"Excellent", cut:"Excellent", polish:"Excellent", flour:"None"}
    @size = @size + 0.1
    task
  end
end
