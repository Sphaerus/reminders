class ProjectsController < ApplicationController
  before_action :authenticate_admin!

  expose(:projects_repository) { ProjectsRepository.new }
  expose(:slack_channels_repository) do
    SlackChannelsRepository.new Slack.client
  end
  expose(:projects) do
    ProjectDecorator.decorate_collection projects_repository.with_done_checks
  end
  expose(:project) do
    params[:id].present? ? projects_repository.find(params[:id]) : Project.new
  end
  expose(:project_checks_repository) { ProjectChecksRepository.new }
  expose(:reminders_repository) { RemindersRepository.new }

  def edit; end

  def index; end

  def create
    project = Projects::Create.new(attrs: project_params).call

    if project.persisted?
      redirect_to projects_path,
                  notice: "Project was successfully created."
    else
      flash.now[:alert] = project.errors.full_messages.join(", ")
      render :new
    end
  end

  def update
    update_project = Projects::Update
                     .new(project: project, attrs: project_params).call
    if update_project.success?
      redirect_to projects_path,
                  notice: "Project was successfully updated."
    else
      self.project = update_project.data
      render :edit
    end
  end

  def archive
    Projects::Archive.new(project).call
    redirect_to projects_path,
                notice: "Project has been archived."
  end

  def unarchive
    Projects::Unarchive.new(project).call
    redirect_to projects_path,
                notice: "Project has been unarchived."
  end

  def toggle_state
    Projects::ToggleState.new(
      project: project,
      projects_repository: projects_repository,
      checks_repository: project_checks_repository,
    ).toggle
    redirect_to projects_path
  end

  private

  def project_params
    params.require(:project).permit(:name, :email, :channel_name)
  end
end
