class AddJiraIssueLeadToReminder < ActiveRecord::Migration[5.0]
  def change
    add_column :reminders, :jira_issue_lead, :integer, default: 7
  end
end
