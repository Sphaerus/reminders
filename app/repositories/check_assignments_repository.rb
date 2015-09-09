class CheckAssignmentsRepository
  def all
    CheckAssignment.all
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

  def delete(assignment_id)
    all.find(assignment_id).destroy
  end

  def update(assignment, parameters)
    assignment.update_attributes(parameters)
    assignment
  end

  def latest_user_assignments(user_id:, limit: 5)
    all.where(user_id: user_id)
      .limit(limit)
      .order(completion_date: :desc, updated_at: :desc)
  end
end
