class CreateDiamonds < ActiveRecord::Migration
  def change
    create_table :diamonds do |t|
      t.string :shape
      t.decimal :size
      t.string :color
      t.string :clarity
      t.string :cut
      t.string :polish
      t.string :sym
      t.string :flour
      t.integer :number_of_results
      t.integer :rap_percentage

      t.timestamps
    end
  end
end
