module ReminderDecorator
  class WithCheckAssignments < Base
    decorates :reminder

    def check_assignments_for_month(year, month)
      start_date = Date.new(year, month).beginning_of_month
      end_date = Date.new(year, month).end_of_month
      assignments = reminder.check_assignments.where(
        'completion_date >= ? AND completion_date < ?', start_date, end_date )
      CheckAssignmentDecorator.decorate_collection(assignments)
    end
  end
end
