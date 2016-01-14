namespace :projects do
  desc "Checks for new projects in DataGuru-API and synchronises them with app"
  task sync_missing: :environment do
    ActiveRecord::Base.connection_pool.with_connection do
      SyncMissingProjectsJob.new(
        projects_repo: ProjectsRepository.new,
        reminders_repo: RemindersRepository.new,
        checks_repo: ProjectChecksRepository.new,
      ).perform
    end
  end
end
