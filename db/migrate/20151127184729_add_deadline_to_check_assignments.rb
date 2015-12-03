class AddDeadlineToCheckAssignments < ActiveRecord::Migration
  def change
    add_column :check_assignments, :deadline, :date
  end
end
