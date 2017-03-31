class ProjectCheckedOnTimeJob
  attr_writer :project_checks_repository
  delegate :valid_for_n_days, :init_valid_for_n_days, to: :reminder

  def initialize(project_check_id)
    @project_check_id = project_check_id
  end

  # rubocop:disable Metrics/AbcSize
  def perform
    if overdue?
      ProjectChecks::HandleOverdue.new(project_check, days_diff).call
    elsif notify?
      ProjectChecks::HandleNotificationDay.new(project_check, days_diff).call
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  attr_reader :project_check_id

  def project_check
    @project_check ||= project_checks_repository.find project_check_id
  end

  def reminder
    @reminder ||= project_check.reminder
  end

  def project_checks_repository
    @project_checks_repository ||= ProjectChecksRepository.new
  end

  def notify?
    if project_check.checked?
      reminder.remind_after_days.any? { |day| day.to_i == days_diff }
    else
      reminder.init_remind_after_days.any? { |day| day.to_i == days_diff }
    end
  end

  def overdue?
    days_diff > (project_check.checked? ? valid_for_n_days : init_valid_for_n_days)
  end

  def days_diff
    @days_diff ||= (Time.zone.today - last_check_date).to_i
  end

  def last_check_date
    last_check = project_check.last_check_date
    without_disabled = project_check.last_check_date_without_disabled_period
    created_at = project_check.created_at.to_date

    [without_disabled, last_check].compact.max || created_at
  end
end
