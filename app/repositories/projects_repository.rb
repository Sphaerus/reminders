class ProjectsRepository
  def all
    Project.where(archived_at: nil).order(:name)
  end

  def archived
    Project.where.not(archived_at: nil)
  end

  def add(params)
    Project.create(params)
  end

  def find(project_id)
    Project.find_by(id: project_id)
  end

  def with_archived
    Project.all.order(:name)
  end

  def with_done_checks
    with_archived.includes(:checked_reviews)
  end

  def persist(entity)
    entity.save
  end

  def for_reminder(reminder)
    reminder.projects
  end

  def for_reminder_with_checks(reminder)
    reminder.projects
            .includes(project_checks: [:reminder, :last_check_user])
            .distinct
  end

  def update(project, update_params)
    project.update_attributes(update_params)
  end

  delegate :find_by_name, to: :all
end
