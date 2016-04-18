module CheckAssignments
  class CreateCompleted < Create
    def call(options = {})
      create_completed(options)
    end

    private

    def create_completed(options)
      assignment = create_assignment(options)
      Complete.new(
        assignment: assignment,
        checker: checker,
        project_check: project_check,
      ).call
    end
  end
end
