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

      if channel_exists?(channel)
        responses << client.chat_postMessage(
          notifier_message(message: message, channel: "##{channel}"),
        )
      elsif channel_changed_name?(channel)
        channel_id = get_channel_id(channel)
        responses << client.chat_postMessage(
          notifier_message(message: message, channel: channel_id),
        )
      end

      @result = responses.all? { |r| r["ok"] }
    end
  end

  def channels(options)
    channels = options.fetch(:channels, [])
    channels = channels.split if channels.is_a?(String)
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

  def channels_list
    @channels_list ||= client.channels_list["channels"]
  end

  def channel_exists?(name)
    channels_list.select { |c| c["name"] == name }.any?
  end

  def channel_changed_name?(name)
    channels_list.select { |c| c["previous_names"].include?(name) }.any?
  end

  def get_channel_id(name)
    channels_list.select { |c| c["previous_names"].include?(name) }.first["id"]
  end
end
