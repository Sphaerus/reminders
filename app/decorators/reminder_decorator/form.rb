module ReminderDecorator
  class Form < Base
    decorates :reminder
    delegate :to_key, :errors

    def remind_after_days
      object.remind_after_days.join(", ")
    end

    def init_remind_after_days
      object.init_remind_after_days.join(", ")
    end
  end
end
