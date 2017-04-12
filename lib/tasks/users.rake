require "rake"

namespace :users do
  desc "Archives user with a given email"
  task :archive, [:email] => :environment do |_task, args|
    email = args[:email]
    validate_email_presence(args[:email])

    user = find_user_by_email(email)
    Users::Archive.new(user).call
    puts "SUCCESS: User #{user} (#{email}) archived."
  end

  desc "Add email to users"
  task migrate_emails: :environment do
    users = UsersRepository.new.all
    users.each do |user|
      next if user.email.present?
      user.update_column(:email, prepare_email(user.name))
    end
  end

  private

  def validate_email_presence(email)
    raise "ERROR: please provide an email in order to archive user!" if email.blank?
  end

  def prepare_email(name)
    name.parameterize.tr("-", ".") + "@#{AppConfig.domain}"
  end

  def find_user_by_email(email)
    user = UsersRepository.new.find_by(email: email)
  rescue ActiveRecord::RecrodNotFound
    raise "ERROR: can't find user with email: '#{email}'!"
  end
end
