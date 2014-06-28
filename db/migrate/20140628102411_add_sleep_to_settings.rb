class AddSleepToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :sleep_time, :integer
  end
end
