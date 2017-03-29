module ReminderDecorator
  class Base < BaseDecorator
    delegate :id, :name, :valid_for_n_days, :deadline_text, :notification_text,
             :persisted?, :slack_channel, :supervisor_slack_channel, :notify_projects_channels,
             :jira_issue_lead, :init_valid_for_n_days, :init_deadline_text, :init_notification_text
    decorates :reminder

    def init_remind_after_days
      as_list(:init_remind_after_days)
    end

    def remind_after_days
      as_list(:remind_after_days)
    end

    def number_of_overdue_project
      ProjectCheckDecorator.decorate_collection(object.project_checks)
                           .count(&:overdue?)
    end

    def slack_channel_display
      slack_channel.presence || not_specified
    end

    def supervisor_slack_channel_display
      supervisor_slack_channel.presence || not_specified
    end

    private

    def not_specified
      I18n.t("reminders.not_specified")
    end

    def as_list(attribute)
      I18n.t("reminders.no_before_deadline") unless object.public_send(attribute).any?
      object.public_send(attribute).join(", ")
    end
  end
end
