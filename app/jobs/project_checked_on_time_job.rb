class ProjectCheckedOnTimeJob
  attr_writer :project_checks_repository
  delegate :valid_for_n_days, :init_valid_for_n_days, to: :reminder

  def initialize(project_check_id)
    @project_check_id = project_check_id
  end

  def perform
    handler = select_handler
    return if handler.nil?
    handler.new(project_check, policy.elapsed_days).call
  end

  private

  attr_reader :project_check_id

  def select_handler
    if policy.overdue?
      ProjectChecks::HandleOverdue
    elsif policy.remind_today?
      ProjectChecks::HandleNotificationDay
    end
  end

  def project_check
    @project_check ||= project_checks_repository.find project_check_id
  end

  def reminder
    @reminder ||= project_check.reminder
  end

  def policy
    @policy ||= DueDatePolicy.new(project_check)
  end

  def project_checks_repository
    @project_checks_repository ||= ProjectChecksRepository.new
  end
end
