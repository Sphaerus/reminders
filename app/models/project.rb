class Project < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :email, presence: true
  validates :channel_name, presence: true
  has_many :project_checks, dependent: :destroy
  has_many :reminders, through: :project_checks
  has_many :checked_reviews,
           -> { where.not(last_check_date: nil).order(created_at: :desc) },
           class_name: "ProjectCheck"
end
