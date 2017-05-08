class AddJiraProjectKeyToReminders < ActiveRecord::Migration[5.0]
  def change
    add_column :reminders, :jira_project_key, :string  
  end
end
