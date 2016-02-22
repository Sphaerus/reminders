module CheckAssignments
  class Complete
    attr_reader :assignments_repository, :assignment,
                :checker, :project_check_update, :completion_date
    private :assignments_repository, :assignment,
            :checker, :project_check_update, :completion_date

    def initialize(assignment:, checker:, project_check:, completion_date: nil)
      @assignment = assignment
      @checker = checker
      @assignments_repository = CheckAssignmentsRepository.new
      @project_check_update =
        ProjectChecks::Update.new(check: project_check)
      @completion_date = completion_date || Time.current
    end

    def call
      complete_assignment
    end

    private

    def complete_assignment
      assignments_repository.update(
        assignment,
        completion_date: completion_date, user_id: checker.id,
      )
      project_check_update.call(
        last_check_date: assignment.completion_date,
        last_check_user_id: checker.id,
      )
    end
  end
end
