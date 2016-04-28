module CheckAssignments
  class Notify
    attr_reader :notifier

    def initialize
      @notifier = Notifier.new
    end

    def call(channel_name, message)
      return unsuccessful_notification(message) unless notifier.slack_enabled?

      channel = prep_channel_name(channel_name)
      slack_message = slack_message(message)

      output = notifier.notify_slack(slack_message, channel: channel)
      final_notice(output, message)
    end

    private

    def prep_channel_name(channel_name)
      "##{channel_name}"
    end

    def slack_message(message)
      "Just letting you know that " + message
    end

    def unsuccessful_notification(message)
      message +
        " Something went wrong and we couldn't notify channel."
    end

    def final_notice(notifier_output, message)
      if notifier_output["ok"]
        message + " We have notified project's channel."
      else
        unsuccessful_notification(message)
      end
    end
  end
end
