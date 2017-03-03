class CheckAssignmentsRepository
  def all
    CheckAssignment.all
  end

  def find(id)
    all.find_by_id id
  end

  def latest_assignment(project_check, completed: false)
    query = all.where(project_check_id: project_check.id)
    if completed
      query.where("completion_date IS NOT NULL").order("completion_date ASC")
    else
      query
    end.last
  end

  def from_last_n_days_for_users(number_of_days, user_ids)
    all.where("completion_date >= ? OR completion_date IS NULL",
              number_of_days.days.ago)
       .where(user_id: user_ids)
  end

  def add(parameters)
    CheckAssignment.create(parameters)
  end

  def delete(assignment)
    id = if assignment.is_a?(CheckAssignment)
           assignment.id
         else
           assignment
         end
    all.find(id).destroy
  end

  def update(assignment, parameters)
    assignment.update_attributes(parameters)
    assignment
  end

  def latest_user_assignments(user_id:, limit: 5)
    all.where(user_id: user_id)
       .includes(project_check: [:project, :reminder])
       .limit(limit)
       .order(completion_date: :desc, updated_at: :desc)
  end

  def for_reminder_in_month_and_year(reminder, year, month)
    start_date = Date.new(year, month).beginning_of_month
    end_date = Date.new(year, month).end_of_month
    all.includes(:project_check).where(
      project_checks: { reminder_id: reminder.id },
      completion_date: start_date..end_date).order(:completion_date)
  end

  def pending_for_project_check_ids(project_check_ids)
    all.where(project_check_id: project_check_ids, completion_date: nil)
  end

  def delete_all(assignments)
    assignments.delete_all
  end
end
