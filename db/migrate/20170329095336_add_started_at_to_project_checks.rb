class AddStartedAtToProjectChecks < ActiveRecord::Migration[5.0]
  def change
    add_column :project_checks, :created_at_without_disabled_period, :datetime
  end
end
