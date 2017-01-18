class AddPmSlackNameToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :pm_slack_name, :string
  end
end
