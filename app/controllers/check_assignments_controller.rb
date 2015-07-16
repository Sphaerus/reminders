class CheckAssignmentsController < ApplicationController
  expose(:project_checks_repository) { ProjectChecksRepository.new }
  expose(:check) do
    project_checks_repository.find(params[:project_check_id])
  end
  expose(:assignments_repository) { CheckAssignmentsRepository.new }
  expose(:assignment) { assignments_repository.latest_assignment(check) }
  expose(:last_checker) do
    assignment.nil? ? nil : assignment.user
  end
  expose(:action_resolver) do
    CheckAssignments::ResolveAction.new(
      assignment: assignment,
      creator: assignment_creator,
      completer: assignment_completer,
    )
  end
  expose(:assignment_creator) do
    CheckAssignments::CreateCompleted.new(
      checker: current_user,
      project_check: check,
    )
  end
  expose(:assignment_completer) do
    CheckAssignments::Complete.new(
      assignment: assignment,
      checker: current_user,
      project_check: check,
    )
  end
  expose(:user_assigner) do
    CheckAssignments::AssignPerson.new(
      project_check: check,
      assignments_repo: assignments_repository,
      users_repo: UsersRepository.new,
    )
  end

  def assign_checker
    if action_resolver.can_create?
      notice = user_assigner.assign(last_checker)
      redirect_to reminder_path(check.reminder),
                  notice: notice
    else
      redirect_to reminder_path(check.reminder),
                  notice: "Someone is already assigned to do this"
    end
  end

  def complete_check
    action_resolver.resolve

    redirect_to reminder_path(check.reminder), notice: "All right"
  end
end
