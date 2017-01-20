module ProjectChecks
  class HandleOverdue
    attr_accessor :check, :days_diff, :mailer

    def initialize(check, days_diff, mailer = nil)
      self.check = check
      self.days_diff = days_diff
      self.mailer = mailer || ProjectNotificationMailer
    end

    def call
      notify!
      mail!
    end

    private

    def mail!
      return unless email_enabled?
      mailer.check_reminder(notification, check).deliver_now
    end

    def email_enabled?
      check.reminder.slack_channel.nil?
    end

    def notify!
      notify(check.decorate.slack_channel, notification)
      # notify_project_manager
    end

    def reminder
      check.reminder
    end

    def project
      check.project
    end

    def notification
      Liquid::Template.parse(notification_template)
                      .render(available_variables)
    end

    def notification_template
      reminder.deadline_text
    end

    def notify(channel, notification, is_user = nil)
      CheckAssignments::Notify.new.call(channel, notification, is_user)
    end

    def notify_project_manager
      return unless check.decorate.pm_slack_name
      notify(check.decorate.pm_slack_name, notification, true)
    end

    def available_variables
      {
        reminder_name: reminder.name,
        project_name: project.name,
        days_ago: days_diff,
        valid_for: reminder.valid_for_n_days,
      }.stringify_keys
    end
  end
end
