module CheckAssignments
  class ClearPending
    attr_reader :project, :assignments_repo, :project_checks_repo

    def initialize(project:, assignments_repo: nil, project_checks_repo: nil)
      @project = project
      @assignments_repo = assignments_repo || CheckAssignmentsRepository.new
      @project_checks_repo = project_checks_repo || ProjectChecksRepository.new
    end

    def call
      clear_pending_assignments
    end

    private

    def clear_pending_assignments
      project_check_ids = project_checks_repo.ids_for_project(project)
      assignments_repo.delete_all(
        assignments_repo.pending_for_project_check_ids(project_check_ids),
      )
    end
  end
end
