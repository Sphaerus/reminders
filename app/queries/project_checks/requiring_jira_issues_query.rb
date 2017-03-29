module ProjectChecks
  class RequiringJiraIssuesQuery
    def initialize(relation = ProjectCheck, params = {})
      @relation = relation
      @date = params.fetch(:date, Time.zone.today)
    end

    def all
      relation
        .includes(:reminder)
        .includes(:project)
        .enabled
        .without_jira_issue
        .where.not(reminders: { jira_issue_lead: nil })
        .where(dates_query)
    end

    private

    attr_reader :date, :relation

    def dates_query
      <<-SQL
        (last_check_date IS NULL
          AND '#{date}' >= (date(project_checks.created_at) + reminders.init_valid_for_n_days
                          - reminders.jira_issue_lead))
        OR
        ((last_check_date IS NOT NULL OR last_check_date_without_disabled_period IS NOT NULL)
          AND '#{date}' >= (GREATEST(last_check_date, last_check_date_without_disabled_period)
                           + reminders.valid_for_n_days - reminders.jira_issue_lead))
      SQL
    end
  end
end
