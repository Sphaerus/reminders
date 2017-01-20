class VisitorsController < ApplicationController
  # skip_before_action :authenticate_user!

  expose(:user_check_assignments) do
    assignments_repository.latest_user_assignments(user_id: current_user.id)
  end
  expose(:assignments_repository) { CheckAssignmentsRepository.new }
end
