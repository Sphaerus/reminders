module Reminders
  class Create
    attr_accessor :attrs, :reminders_repository

    def initialize(attrs, reminders_repository = RemindersRepository.new)
      self.attrs = attrs
      self.reminders_repository = reminders_repository
    end

    def call
      self.attrs = format_attributes attrs
      reminder = Reminder.new attrs
      if reminder.valid?
        reminders_repository.create(reminder)
        Response::Success.new data: reminder
      else
        Response::Error.new data: reminder
      end
    end

    private

    def format_attributes(reminder_attrs)
      %i(init_remind_after_days remind_after_days).each do |attr|
        days = reminder_attrs[attr] || ""
        days = days.split(",").map(&:strip).map(&:to_i).uniq.sort - [0]
        reminder_attrs[attr] = days
      end
      reminder_attrs
    end
  end
end
