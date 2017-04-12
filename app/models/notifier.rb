class Notifier
  attr_accessor :client, :slack_enabled, :responses, :result

  def initialize(client = Slack.client)
    self.client = client
    self.responses = []
  end

  def send_message(message, options = {})
    notify_slack message, options
  end

  def notify_slack(message, options)
    options.fetch(:channels, []).each do |channel|
      Rails.logger.info "##{channel}: #{message}"
      unless slack_enabled?
        responses << { ok: true }
        next
      end

      responses << client.chat_postMessage(
        notifier_message(message: message, channel: "##{channel}"),
      )
    end
  end

  def slack_enabled?
    @slack_enabled || AppConfig.slack_enabled.to_s == "true"
  end

  def notifier_message(message:, channel:)
    {
      text: message,
      channel: channel,
      username: "Reminders App",
      icon_emoji: ":loudspeaker:",
    }
  end
end
