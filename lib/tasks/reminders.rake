namespace :reminders do
  desc "Checks all the reminders if the dates are correct"
  task check_all: :environment do
    ActiveRecord::Base.connection_pool.with_connection do
      RemindersRepository.new.all.each do |reminder|
        CheckReminderJob.new.perform reminder.id
      end
    end
  end

  desc "Create missing issues for all reminders"
  task create_jira_issues: :environment do
    CreateJiraIssuesJob.perform
  end
end
