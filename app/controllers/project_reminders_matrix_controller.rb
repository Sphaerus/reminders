class ProjectRemindersMatrixController < ApplicationController
  before_action :authenticate_admin!

  expose(:reminders_repository) { RemindersRepository.new }
  expose(:reminders) do
    ReminderDecorator::Base.decorate_collection(
      reminders_repository.all.includes(:project_checks))
  end
  expose(:projects_repository) { ProjectsRepository.new }
  expose(:projects) do
    ProjectDecorator.decorate_collection(projects_repository.all).select { |p| p.enabled && p.archived_at.nil? }
  end
  expose(:project_checks_repo) { ProjectChecksRepository.new }

  def index
  end
end
