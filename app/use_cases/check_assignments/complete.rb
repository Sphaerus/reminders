module CheckAssignments
  class Complete
    attr_reader :assignments_repository, :assignment, :project_check,
                :checker, :project_check_update, :completion_date
    private :assignments_repository, :assignment, :project_check,
            :checker, :project_check_update, :completion_date

    def initialize(assignment:, checker:, project_check:, completion_date: nil)
      @assignment = assignment
      @checker = checker
      @assignments_repository = CheckAssignmentsRepository.new
      @project_check = project_check
      @project_check_update =
        ProjectChecks::Update.new(check: project_check)
      @completion_date = completion_date || Time.current
    end

    def call(options = {})
      complete_assignment(options)
    end

    private

    def complete_assignment(options)
      assignments_repository.update(
        assignment,
        options.merge(completion_date: completion_date, user_id: checker.id),
      )
      project_check_update.call(
        last_check_date: assignment.completion_date,
        last_check_user_id: checker.id,
      )
      notify_supervisor_channel
    end

    def notify_supervisor_channel
      return unless project_check.reminder.notify_supervisor?
      decorated = project_check.decorate
      CheckAssignments::Notify.new.call(
        decorated.supervisor_slack_channel,
        decorated.completion_notification_text(checker),
      )
    end
  end
end
