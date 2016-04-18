module CheckAssignments
  class ResolveAction
    attr_reader :assignment, :assignment_creator, :assignment_completer
    private :assignment, :assignment_creator, :assignment_completer

    def initialize(assignment:, creator:, completer:)
      @assignment = assignment
      @assignment_creator = creator
      @assignment_completer = completer
    end

    def resolve(options = {})
      return if assignment_creator.nil? || assignment_completer.nil?
      if can_create?
        assignment_creator.call(options)
      else
        assignment_completer.call(options)
      end
    end

    def can_create?
      assignment.nil? || assignment.completion_date.present?
    end
  end
end
