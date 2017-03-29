class AddInitColumnsToReminders < ActiveRecord::Migration[5.0]
  def up
    add_column :reminders, :init_valid_for_n_days,  :integer
    add_column :reminders, :init_remind_after_days, :text,    array: true, default: []
    add_column :reminders, :init_deadline_text,     :text
    add_column :reminders, :init_notification_text, :text

    ActiveRecord::Base.connection.execute(update_sql)
  end
  
  def down
    remove_column :reminders, :init_valid_for_n_days
    remove_column :reminders, :init_remind_after_days
    remove_column :reminders, :init_deadline_text
    remove_column :reminders, :init_notification_text
  end

  def update_sql
    <<-SQL
      UPDATE reminders
      SET init_valid_for_n_days = valid_for_n_days,
          init_remind_after_days = remind_after_days,
          init_deadline_text = deadline_text,
          init_notification_text = notification_text;
    SQL
  end
end
