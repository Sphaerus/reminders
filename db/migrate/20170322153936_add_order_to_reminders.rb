class AddOrderToReminders < ActiveRecord::Migration[5.0]
  def change
    add_column :reminders, :order, :integer, default: 0
  end
end
