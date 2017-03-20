class AddJiraFieldsToProjectChecks < ActiveRecord::Migration[5.0]
  def change
    add_column :project_checks, :jira_issue_created_at, :datetime
    add_column :project_checks, :jira_issue_key, :string
  end
end
