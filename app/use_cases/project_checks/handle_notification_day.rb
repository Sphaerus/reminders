module ProjectChecks
  class HandleNotificationDay < HandleOverdue
    def message_when_checked
      reminder.notification_text
    end

    def message_when_not_checked
      reminder.init_notification_text
    end
  end
end
