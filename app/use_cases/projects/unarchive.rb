module Projects
  class Unarchive
    attr_accessor :project

    def initialize(project)
      self.project = project
    end

    def call
      project.archived_at = nil
      project.save!
    end
  end
end
