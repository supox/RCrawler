class CreateAdjustments < ActiveRecord::Migration
  def change
    create_table :adjustments do |t|
      t.decimal :weight
      t.string :color
      t.string :clarity
      t.integer :cut_vg
      t.integer :cut_g
      t.integer :sym_vg
      t.integer :sym_g
      t.integer :pol_vg
      t.integer :pol_g
      t.integer :flor_faint
      t.integer :flor_medium
      t.integer :flor_strong

      t.timestamps
    end
  end
end
