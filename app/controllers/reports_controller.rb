class ReportsController < ApplicationController
  expose(:reminders_repository) { RemindersRepository.new }
  expose(:reminders) do
    ReminderDecorator::WithCheckAssignments.decorate_collection(
      reminders_repository.all.includes(:check_assignments))
  end

  expose(:month) { params.fetch(:month, Time.current.month).to_i }
  expose(:year) { params.fetch(:year, Time.current.year).to_i }
  expose(:months) { 1..12}

  def index
  end
end
