module ProjectChecks
  class HandleNotificationDay < HandleOverdue
    def notification_template
      reminder.notification_text
    end
  end
end
