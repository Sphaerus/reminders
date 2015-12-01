class AddDeadlineToCheckAppointments < ActiveRecord::Migration
  def change
    add_column :check_appointments, :deadline, :date
  end
end
