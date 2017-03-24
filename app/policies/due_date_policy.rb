class DueDatePolicy
  attr_reader :project_check

  delegate :reminder, to: :project_check

  def initialize(project_check)
    @project_check = project_check
  end

  def due_on
    date_to_count_from + reminder.valid_for_n_days
  end

  def due_in
    due_on - Time.zone.today
  end

  def overdue?
    due_in < 0
  end

  def remind_on
    reminder.remind_after_days.map do |days|
      date_to_count_from + days.to_i
    end.sort
  end

  private

  def date_to_count_from
    if checked_before?
      [project_check.last_check_date,
       project_check.last_check_date_without_disabled_period].compact.max
    else
      project_check.created_at
    end.to_date
  end

  def checked_before?
    project_check.last_check_date.present?
  end
end
