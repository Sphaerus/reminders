module Reminders
  class Reorder
    def initialize(reminder, direction, repository = RemindersRepository.new)
      if direction != :up && direction != :down
        raise ArgumentError, "direction must be :up or :down"
      end
      @reminder = reminder
      @direction = direction
      @repository = repository
    end

    def call
      reminders = reorder_reminders_in_an_array
      save_new_order(reminders)
    end

    private

    def reorder_reminders_in_an_array
      reminders = @repository.all.to_a
      index = find_reminder_index(reminders)
      reminders.insert(new_index(index), reminders.delete_at(index))
    end

    def find_reminder_index(reminders)
      reminders.index { |reminder| reminder.id == @reminder.id }
    end

    def new_index(index)
      index += (@direction == :up ? -1 : 1)
      count = @repository.all.count

      if index < 0
        0
      elsif index >= count
        count - 1
      else
        index
      end
    end

    def save_new_order(reminders)
      Reminder.transaction do
        reminders.each_with_index do |reminder, order|
          reminder.update_column(:order, order)
        end
      end
    end
  end
end
