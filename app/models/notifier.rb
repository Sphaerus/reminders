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
        responses << { ok: true }
      end
    end
  end

  def slack_enabled?
    @slack_enabled || AppConfig.slack_enabled.to_s == "true"
  end
end
