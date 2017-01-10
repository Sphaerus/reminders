module ProjectChecks
  class HandleNotificationDay < HandleOverdue
    def notification_template
      reminder.notification_text
    end

    def notify!
      project_channel.present? && ['members'].each do |member|
        notifier
          .send_message notification, channel: member
      end
    end

    def project_channel
      notifier.client.channels_list['channels'].detect { |channel| channel['name'] == check.project.channel_name }
    end
  end
end
