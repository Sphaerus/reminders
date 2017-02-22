module Projects
  class Archive
    attr_accessor :project

    def initialize(project)
      self.project = project
    end

    def call
      project.archived_at = Time.current
      project.save!
      CheckAssignments::ClearPending.new(project: project).call
    end
  end
end
