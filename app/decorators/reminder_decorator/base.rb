module ReminderDecorator
  class Base < BaseDecorator
    delegate :id, :name, :valid_for_n_days, :deadline_text, :notification_text,
             :persisted?, :slack_channel, :supervisor_slack_channel, :notify_projects_channels
    decorates :reminder

    def remind_after_days
      if object.remind_after_days.any?
        object.remind_after_days.join(", ")
      else
        "No reminders before deadline"
      end
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
      "Not specified."
    end
  end
end
