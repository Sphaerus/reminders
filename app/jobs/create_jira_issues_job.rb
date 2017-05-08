class CreateJiraIssuesJob
  class << self
    def perform
      new.perform
    end
  end

  def perform
    project_checks.each do |check|
      issue = Jira.create_issue_from_project(project: check.project, reminder: check.reminder)
      if issue.is_a?(Hash) && issue.key?("key")
        check.update_columns(jira_issue_key: issue["key"], jira_issue_created_at: Time.zone.now)
      end
    end
    project_checks
  end

  private

  def project_checks
    @project_checks ||= ProjectChecksRepository.new.requiring_jira_issues
  end
end
