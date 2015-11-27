class AddInfoToProjectChecks < ActiveRecord::Migration
  def change
    add_column :project_checks, :info, :text
  end
end
