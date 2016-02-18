module ReminderDecorator
  class Base < Draper::Decorator
    delegate :id, :name, :valid_for_n_days, :deadline_text, :notification_text,
             :persisted?, :slack_channel
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
      if slack_channel.present?
        slack_channel
      else
        "Not specified."
      end
    end
  end
end
