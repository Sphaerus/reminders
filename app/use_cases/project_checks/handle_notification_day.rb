module ProjectChecks
  class HandleNotificationDay < HandleOverdue
    def notification_template
      reminder.notification_text
    end

    def notify!
      notifier
        .send_message notification, channel: "##{check.decorate.slack_channel}"
      notify_team_members!
    end

    def notify_team_members!
      project_channel.present? && project_channel['members'].each do |member|
        notifier
          .send_message notification, channel: member
      end
    end

    def project_channel
      notifier.client.channels_list['channels'].detect { |channel| channel['name'] == check.project.channel_name }
    end
  end
end
