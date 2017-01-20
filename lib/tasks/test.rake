namespace :reminders do
  desc "send notification"
  task send_notification: :environment do
    ActiveRecord::Base.connection_pool.with_connection do
       ProjectChecksRepository.new.all.each do |check|
        ProjectChecks::HandleNotificationDay.new(check, 0)
      end
    end
  end
end