class ProjectCheckedOnTimeJob
  attr_accessor :project_check
  attr_writer :project_checks_repository
  attr_reader :project_check_id, :valid_for_n_days, :remind_after_days

  def initialize(project_check_id, valid_for_n_days, remind_after_days)
    @project_check_id = project_check_id
    @valid_for_n_days = valid_for_n_days
    @remind_after_days = remind_after_days
  end

  # rubocop:disable Metrics/AbcSize
  def perform
    self.project_check = project_checks_repository.find project_check_id
    if overdue? valid_for_n_days
      ProjectChecks::HandleOverdue.new(project_check, days_diff).call
    elsif notify? remind_after_days
      ProjectChecks::HandleNotificationDay.new(project_check, days_diff).call
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def project_checks_repository
    @project_checks_repository ||= ProjectChecksRepository.new
  end

  def notify?(remind_after_days)
    remind_after_days.any? { |day| day.to_i == days_diff }
  end

  def overdue?(valid_for_n_days)
    days_diff > valid_for_n_days
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
