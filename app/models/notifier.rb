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
    channels = options.fetch(:channels, [])
    msg = {
      text: message,
      username: "Reminders App",
      icon_emoji: ":loudspeaker:",
    }
    channels.each do |channel|
      if slack_enabled?
        responses << client.chat_postMessage(msg.merge(channel: "##{channel}"))
      else
        Rails.logger.info "##{channel}: #{message}"
        responses << { ok: true }
      end
    end
    @result = responses.all? { |r| r["ok"] }
  end

  def slack_enabled?
    @slack_enabled || AppConfig.slack_enabled.to_s == "true"
  end
end
