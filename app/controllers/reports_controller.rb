class ReportsController < ApplicationController
  expose(:reminders_repository) { RemindersRepository.new }
  expose(:check_assignments_repo) { CheckAssignmentsRepository.new }
  expose(:reminders) do
    ReminderDecorator::Base.decorate_collection(
      reminders_repository.all.includes(:check_assignments))
  end

  expose(:month) { params.fetch(:month, Time.current.month).to_i }
  expose(:year) { params.fetch(:year, Time.current.year).to_i }
  expose(:months) { 1..12 }

  helper_method :assignments_for_reminder

  def index
  end

  private

  def assignments_for_reminder(reminder)
    CheckAssignmentDecorator.decorate_collection(
      check_assignments_repo.for_reminder_in_month_and_year(
        reminder, year, month))
  end
end
