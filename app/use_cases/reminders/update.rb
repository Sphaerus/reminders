module Reminders
  class Update < Create
    attr_accessor :reminder, :attrs, :reminders_repo

    def initialize(reminder, attrs, reminders_repo = RemindersRepository.new)
      self.reminder = reminder
      self.attrs = attrs
      self.reminders_repo = reminders_repo
    end

    def call
      reminder.assign_attributes format_attributes(attrs)
      if reminder.valid?
        reminders_repo.update(reminder)
        Response::Success.new data: reminder
      else
        Response::Error.new data: reminder
      end
    end
  end
end
