module CheckAssignments
  class Create
    attr_reader :checker, :assignments_repository, :project_check,
                :contact_person
    private :checker, :assignments_repository, :project_check,
            :contact_person

    def initialize(checker:, project_check:, assignments_repository: nil,
                   contact_person:)
      @checker = checker
      @project_check = project_check
      @assignments_repository = assignments_repository ||
                                CheckAssignmentsRepository.new
      @contact_person = contact_person
    end

    def call(options = {})
      create_assignment(options)
    end

    private

    def create_assignment(options)
      assignments_repository.add(prepare_attributes.merge(options))
    end

    def prepare_attributes(_options = {})
      {
        user_id: checker.id,
        project_check_id: project_check.id,
        contact_person_id: contact_person.id,
      }
    end
  end
end
