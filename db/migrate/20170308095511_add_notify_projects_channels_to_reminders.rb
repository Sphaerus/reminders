class AddNotifyProjectsChannelsToReminders < ActiveRecord::Migration[5.0]
  def change
    add_column :reminders, :notify_projects_channels, :boolean, null: false, default: false
  end
end
