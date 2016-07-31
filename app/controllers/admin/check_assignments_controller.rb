module Admin
  class CheckAssignmentsController < AdminController
    expose(:check_assignments_repo) { CheckAssignmentsRepository.new }
    expose(:users_repo) { UsersRepository.new }
    expose(:project_check_repo) { ProjectChecksRepository.new }
    expose(:project_check) do
      project_check_repo.find(params[:project_check_id])
    end
    expose(:check_assignment)

    def create
      assignment = create_assignment
      if assignment.persisted?
        complete_assignment!
        redirect_to history_project_check_path(project_check),
                    notice: "Manual entry added"
      else
        redirect_to history_project_check_path(project_check),
                    alert: "Sorry, can't save this entry. Check the params."
      end
    end

    def edit
    end

    def update
      ca_params = params.require(:check_assignment)
                        .permit(:user_id, :note_url, :completion_date)
      check_assignments_repo.update(check_assignment, ca_params)
      redirect_to reports_path
    end

    def destroy
      CheckAssignments::Delete.new(
        check_assignment_id: params[:id],
        project_check: project_check,
      ).call

      redirect_to history_project_check_path(project_check),
                  notice: "Entry deleted"
    end

    private

    def complete_assignment!
      assignment = check_assignments_repo.latest_assignment(project_check,
                                                            completed: true)
      CheckAssignments::Complete.new(
        assignment: assignment,
        checker: users_repo.find(assignment.user_id),
        project_check: project_check,
        completion_date: assignment.completion_date,
      ).call
    end

    def create_assignment
      attrs = assignment_params.merge(
        project_check_id: project_check.id,
      )
      check_assignments_repo.add(attrs)
    end

    def assignment_params
      params.require(:manual_check).permit(:completion_date, :user_id)
    end
  end
end
