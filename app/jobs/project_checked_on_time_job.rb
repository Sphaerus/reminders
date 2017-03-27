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
    if handler = select_handler
      handler.new(project_check, policy.elapsed_days).call
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def select_handler
    if policy.overdue?
      ProjectChecks::HandleOverdue
    elsif policy.remind_today?
      ProjectChecks::HandleNotificationDay
    end
  end

  def policy
    DueDatePolicy.new(project_check,
                      valid_for_n_days: valid_for_n_days,
                      remind_after_days: remind_after_days)
  end

  def project_checks_repository
    @project_checks_repository ||= ProjectChecksRepository.new
  end
end
