module CheckAssignments
  class RemindPendingCheckAssignment
    attr_reader :project_check, :users_repository, :check_assignments_repository, :reminder

    def initialize(project_check:, reminder:, users_repository: nil,
                   check_assignments_repository: nil)
      @project_check = project_check
      @reminder = reminder
      @users_repository = users_repository || UsersRepository.new
      @check_assignments_repository = check_assignments_repository ||
                                      CheckAssignmentsRepository.new
    end

    def call
      return unless should_remind?
      remind_person
    end

    private

    def remind_person
      UserReminderMailer
        .check_assignment_remind(user, project_check, days_diff)
        .deliver_now
    end

    def check_assignment
      @check_assignment ||= check_assignments_repository
                            .latest_assignment(project_check)
    end

    def user
      users_repository.find(check_assignment.user_id)
    end

    def user_assigned?
      check_assignment.present?
    end

    def should_remind?
      user_assigned? && !user_assigned_today? && !check_assignment_completed? &&
        (overdue? || remind_after_days.any? { |day| day.to_i == days_diff })
    end

    def remind_after_days
      project_check.checked? ? reminder.remind_after_days : reminder.init_remind_after_days
    end

    def overdue?
      days_diff > valid_for_days
    end

    def valid_for_days
      project_check.checked? ? reminder.valid_for_n_days : reminder.init_valid_for_n_days
    end

    def user_assigned_today?
      days_diff == 0
    end

    def check_assignment_completed?
      check_assignment.completion_date.present?
    end

    def days_diff
      @days_diff ||= (Time.zone.today - assignation_date).to_i
    end

    def assignation_date
      check_assignment.created_at.to_date
    end
  end
end
