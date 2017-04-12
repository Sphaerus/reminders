class CheckReminderJob
  # NOTE: this is not a regular ActiveJob class - this class is used as an
  # interface to enqueue all the smaller jobs for a given reminder
  attr_writer :reminders_repository, :project_checks_repository

  def perform(reminder_id)
    reminder = reminders_repository.find reminder_id
    checks_for_reminder(reminder).each do |project_check|
      if all_assigments_completed?(project_check.check_assignments)
        ProjectCheckedOnTimeJob.new(project_check.id).perform
      else
        CheckAssignments::RemindPendingCheckAssignment.new(
          project_check: project_check, reminder: reminder,
        ).call
      end
    end
  end

  private

  def all_assigments_completed?(assignments)
    assignments.none? { |c| c.completion_date.nil? }
  end

  def reminders_repository
    @reminders_repository ||= RemindersRepository.new
  end

  def project_checks_repository
    @project_checks_repository ||= ProjectChecksRepository.new
  end

  def checks_for_reminder(reminder)
    project_checks_repository.for_reminder(reminder).select(&:enabled?)
  end
end
