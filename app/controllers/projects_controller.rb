class ProjectsController < ApplicationController
  before_action :authenticate_admin!, only: [:sync]

  expose(:projects_repository) { ProjectsRepository.new }
  expose(:slack_channels_repository) do
    SlackChannelsRepository.new Slack.client
  end
  expose(:projects) do
    ProjectDecorator.decorate_collection projects_repository.with_done_checks
  end

  def index; end

  def sync
    Projects::SyncWithSlackChannels.new(projects_repository,
                                        slack_channels_repository).call
    redirect_to projects_path, notice: "Projects have been synchronized"
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end
end
