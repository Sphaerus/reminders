module Projects
  class Create
    attr_accessor :attrs, :projects_repo, :project

    def initialize(attrs:, projects_repo: ProjectsRepository.new)
      @project = project
      @attrs = attrs
      @projects_repo = projects_repo
    end

    def call
      projects_repo.add(attrs)
    end
  end
end
