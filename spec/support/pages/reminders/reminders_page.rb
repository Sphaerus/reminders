require_relative "./sections/reminder_table_row.rb"

module Reminders
  class RemindersPage < SitePrism::Page
    set_url "/reminders"
    sections :reminder_rows, ReminderTableRow,
             "#reminders-table tbody tr"

    def names
      reminder_rows.map do |row|
        row.name.text
      end
    end
  end
end
