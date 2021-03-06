module ProjectChecks
  class HandleOverdue
    attr_accessor :check, :days_diff, :notifier, :mailer

    def initialize(check, days_diff, notifier = nil, mailer = nil)
      self.check = check
      self.days_diff = days_diff
      self.notifier = notifier || Notifier.new
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
      notifier
        .send_message(notification, channels: check.decorate.slack_channels)
    end

    def reminder
      check.reminder
    end

    def project
      check.project
    end

    def notification
      Liquid::Template.parse(message_text)
                      .render(available_variables)
    end

    def message_text
      check.checked? ? message_when_checked : message_when_not_checked
    end

    def message_when_checked
      reminder.deadline_text
    end

    def message_when_not_checked
      reminder.init_deadline_text
    end

    def available_variables
      {
        reminder_name: reminder.name,
        project_name: project.name,
        days_ago: days_diff,
        valid_for:  valid_for_days,
      }.stringify_keys
    end

    def valid_for_days
      check.checked? ? reminder.valid_for_n_days : reminder.init_valid_for_n_days
    end
  end
end
