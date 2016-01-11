module Projects
  class SyncWithDataGuru
    include ::DataGuruClient

    attr_accessor :projects_repository, :projects_names

    def initialize(projects_repository)
      self.projects_repository = projects_repository
    end

    def call
      get_projects
      @projects.each do |project|
        project_name = project.display_name
        channel_name = project.slack_project_channel_name
        unless projects_names.include? project_name
          save_project project_name, channel_name
        end
      end
    end

    private

    def get_projects
      @projects = data_guru.projects.all
    end

    def projects_names
      @projects_names ||= projects_repository.all.pluck(:name)
    end

    def save_project(name, channel_name)
      projects_repository.persist Project.new(name: name,
                                              channel_name: channel_name,
                                              email: prepare_email(name))
    end

    def prepare_email(name)
      "#{name.downcase}-team@#{AppConfig.domain}"
    end
  end
end
