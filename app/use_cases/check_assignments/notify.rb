module CheckAssignments
  class Notify
    attr_reader :notifier

    def initialize
      @notifier = Notifier.new
    end

    def call(channels, message)
      return unsuccessful_notification(message) unless notifier.slack_enabled?

      slack_message = "Just letting you know that #{message}"

      notifier.notify_slack(slack_message, channels: channels)
      final_notice(message)
    end

    private

    def unsuccessful_notification(message)
      message +
        " Something went wrong and we couldn't notify channel."
    end

    def final_notice(message)
      if notifier.result
        "#{message} We have notified project's channel."
      else
        unsuccessful_notification(message)
      end
    end
  end
end
