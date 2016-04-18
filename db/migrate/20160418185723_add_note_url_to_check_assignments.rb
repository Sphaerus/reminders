class AddNoteUrlToCheckAssignments < ActiveRecord::Migration
  def change
    add_column :check_assignments, :note_url, :string
  end
end
