# cronotab.rb — Crono configuration file

require 'rake'

Rails.app_class.load_tasks

class CronRemindersCheckAll
  def perform
    Rake::Task["reminders:check_all"].execute
  end
end

Crono.perform(CronRemindersCheckAll).every 1.week, on: :monday, at: {hour: 9, min: 30}
Crono.perform(CronRemindersCheckAll).every 1.week, on: :tuesday, at: {hour: 9, min: 30}
Crono.perform(CronRemindersCheckAll).every 1.week, on: :wednesday, at: {hour: 9, min: 30}
Crono.perform(CronRemindersCheckAll).every 1.week, on: :thursday, at: {hour: 9, min: 30}
Crono.perform(CronRemindersCheckAll).every 1.week, on: :friday, at: {hour: 9, min: 30}
