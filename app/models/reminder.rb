class Reminder < ActiveRecord::Base
  validates :name, presence: true, length: { minimum: 3 }
  validates :deadline_text, :notification_text, presence: true,
                                                length: { minimum: 10 }
  validates :valid_for_n_days, numericality: true
  has_many :project_checks, dependent: :destroy
  has_many :projects, through: :project_checks
  has_many :check_assignments, through: :project_checks, dependent: :destroy
  has_many :skills, dependent: :destroy

  def notify_supervisor?
    supervisor_slack_channel.present?
  end
end
