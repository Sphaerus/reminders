class ProjectCheck < ActiveRecord::Base
  belongs_to :project
  belongs_to :reminder
  belongs_to :last_check_user, class_name: "User"

  has_many :check_assignments, -> { order created_at: :desc },
           dependent: :destroy

  validate :project_enabled?

  scope :enabled, -> { where(enabled: true) }
  scope :without_jira_issue, -> { where(jira_issue_key: nil) }

  private

  def project_enabled?
    return unless enabled? && project.present? && !project.enabled?
    errors[:base] << "
      Can't enable project checks belonging to a disabled project
    "
  end
end
