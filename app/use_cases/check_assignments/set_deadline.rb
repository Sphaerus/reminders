module CheckAssignments
  class SetDeadline
    attr_reader :assignment, :assignments_repository, :deadline

    def initialize(assignment:, assignments_repository:, deadline:)
      @assignment = assignment
      @deadline = deadline
      @assignments_repository = assignments_repository
    end

    def call
      if assignments_repository.update(assignment, deadline: deadline)
        Response::Success.new data: assignment
      else
        Response::Error.new data: assignment
      end
    end
  end
end
