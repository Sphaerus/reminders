module CheckAssignments
  class Cancel
    attr_reader :check_assignment, :check_assignments_repo

    def initialize(check_assignment,
                   check_assignments_repo: CheckAssignmentsRepository.new)
      @check_assignment = check_assignment
      @check_assignments_repo = check_assignments_repo
    end

    def call
      remove_check_assignment
      notify_user
      display_notice
    end

    private

    def display_notice
      "The previous assignment has been canceled."
    end

    def remove_check_assignment
      check_assignments_repo.delete(check_assignment)
    end

    def notify_user
      CanceledAssignmentUserNotificationMailer
        .canceled_assignment(check_assignment.user,
                             check_assignment.project_check)
        .deliver_now
    end
  end
end
