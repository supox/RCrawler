class AddSearchIndicesToDiamond < ActiveRecord::Migration
  def change
    add_index :diamonds, [ :size, :color, :clarity, :cut, :polish, :sym, :flour ], unique:true, name: 'index_params_match'
  end
end

