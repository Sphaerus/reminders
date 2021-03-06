class DueDatePolicy
  attr_reader :project_check, :reminder

  def initialize(project_check)
    @project_check = project_check
    @reminder = project_check.reminder
  end

  def due_in
    (due_on - Time.zone.today).to_i
  end

  def overdue?
    due_in < 0
  end

  def remind_today?
    remind_on?(Time.zone.today)
  end

  def elapsed_days
    (Time.zone.today - date_to_count_from).to_i
  end

  private

  def due_on
    date_to_count_from + valid_for_n_days
  end

  def remind_on
    remind_after_days.map do |days|
      date_to_count_from + days.to_i
    end.sort
  end

  def remind_on?(date)
    remind_on.include?(date.to_date)
  end

  def date_to_count_from
    if checked_before?
      [project_check.last_check_date,
       project_check.last_check_date_without_disabled_period].compact.max
    else
      project_check.created_at_without_disabled_period || project_check.created_at
    end.to_date
  end

  def checked_before?
    project_check.last_check_date.present?
  end

  def valid_for_n_days
    checked_before? ? reminder.valid_for_n_days : reminder.init_valid_for_n_days
  end

  def remind_after_days
    checked_before? ? reminder.remind_after_days : reminder.init_remind_after_days
  end
end
