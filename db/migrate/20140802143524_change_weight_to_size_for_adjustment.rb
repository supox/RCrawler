class ChangeWeightToSizeForAdjustment < ActiveRecord::Migration
  def change
    change_table :adjustments do |t|
      t.rename :weight, :size
    end
  end
end
