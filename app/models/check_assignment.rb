class CheckAssignment < ActiveRecord::Base
  belongs_to :project_check
  belongs_to :user
  belongs_to :contact_person, class_name: "User"

  validates :user, presence: true
end
