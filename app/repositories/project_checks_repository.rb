class ProjectChecksRepository
  def all
    ProjectCheck.all.includes(:project)
  end

  def for_reminder(reminder)
    all.includes(:project, :reminder,
                 :last_check_user,
                 check_assignments: :user
                )
       .where(reminder_id: reminder.id)
       .where("projects.archived_at IS NULL")
       .order("projects.name")
  end

  def create(entity)
    persist entity
  end

  def persist(entity)
    entity.save
  end

  def find(id)
    all.find_by_id id
  end

  def update(check, update_params)
    check.update_attributes(update_params)
  end
end
