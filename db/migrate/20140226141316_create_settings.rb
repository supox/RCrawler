class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :rap_username
      t.string :rap_password
      t.integer :price_list_extra_discount
      t.integer :price_list_min_number_of_results_to_display
      t.boolean :start_xvfb
      t.decimal :ranges_size_start
      t.decimal :ranges_size_end
      t.string :ranges_cut, array:true, length:4
      t.string :ranges_polish, array:true, length:4
      t.string :ranges_sym, array:true, length:4
      t.string :ranges_clarity, array:true, length:8
      t.string :ranges_color_start
      t.string :ranges_color_end
      t.string :ranges_flour, array:true, length:5

      t.timestamps
    end
  end
end
