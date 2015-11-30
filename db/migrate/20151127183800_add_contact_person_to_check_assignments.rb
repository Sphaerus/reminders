class AddContactPersonToCheckAssignments < ActiveRecord::Migration
  def change
    add_reference :check_assignments, :contact_person, index: true
  end
end
