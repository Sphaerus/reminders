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
    channels(options).each do |channel|
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

  def channels(options)
    channels = options.fetch(:channels, [])
    channels = channels.split(" ") if channels.is_a?(String)
    channels
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
