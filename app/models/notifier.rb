class Notifier
  attr_accessor :client, :slack_enabled

  def initialize(client = Slack.client)
    self.client = client
  end

  def send_message(message, options = {})
    if slack_enabled?
      notify_slack(message, options)
    else
      Rails.logger.info message
    end
  end

  def notify_slack(message, options)
    channels = options.fetch(:channel, "").split(" ")
    msg = {
      text: message,
      username: "Reminders App",
      icon_emoji: ":loudspeaker:",
    }
    channels.each do |channel|
      client.chat_postMessage msg.merge(channel: "##{channel}")
    end
  end

  def slack_enabled?
    @slack_enabled || AppConfig.slack_enabled.to_s == "true"
  end
end
