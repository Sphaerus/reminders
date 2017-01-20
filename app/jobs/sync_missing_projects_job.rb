class SyncMissingProjectsJob
  attr_reader :projects_repository,
              :reminders_repository,
              :project_checks_repository

  def initialize(projects_repo:, reminders_repo:, checks_repo:)
    @projects_repository = projects_repo
    @reminders_repository = reminders_repo
    @project_checks_repository = checks_repo
  end

  def perform
    puts 'lol'
    sync_projects_with_data_guru
    sync_with_reminders
  end

  private

  def sync_projects_with_data_guru
    Projects::SyncWithDataGuru
      .new(projects_repository)
      .call
  end

  def sync_with_reminders
    reminders_repository.all.each do |reminder|
      Reminders::SyncProjects
        .new(reminder, projects_repository, project_checks_repository)
        .call
    end
  end
end
