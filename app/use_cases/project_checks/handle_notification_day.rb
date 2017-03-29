module ProjectChecks
  class HandleNotificationDay < HandleOverdue
    def notification_template
      check.checked? ? reminder.notification_text : reminder.init_notification_text
    end
  end
end
