class AddSupervisorSlackChannelToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :supervisor_slack_channel, :string
  end
end
