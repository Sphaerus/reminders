class Jira
  class << self
    def create_issue_from_project(project:, reminder:)
      new(project: project, reminder: reminder).create_issue_from_project
    end
  end

  def initialize(options)
    @options = options
  end

  def create_issue_from_project
    return create_jira_issue if settings.enabled?
    log_jira_issue
  end

  private

  attr_reader :options

  def create_jira_issue
    response = RestClient.post("#{settings.endpoint}/issue", jira_params.to_json, headers)

    return false unless response.code == 201
    JSON.parse response.body
  end

  def log_jira_issue
    Rails.logger.info "Jira params: #{jira_params}"
    false
  end

  def jira_params
    {
      fields: {
        project: { key: jira_project_key },
        issuetype: { name: settings.issue_type },
        summary: "#{settings.summary} #{options.fetch(:project).name}",
      },
    }
  end

  def settings
    @settings ||= AppConfig.jira
  end

  def jira_project_key
    binding.pry
    @jira_project_key ||= options.fetch(:reminder).jira_project_key || settings.project_key
  end

  def headers
    { content_type: :json, accept: :json, authorization: authorization }
  end

  def authorization
    "Basic #{Base64.strict_encode64("#{settings.username}:#{settings.password}")}"
  end
end
