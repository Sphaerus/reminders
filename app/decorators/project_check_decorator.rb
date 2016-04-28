class ProjectCheckDecorator < Draper::Decorator
  delegate_all

  def check_assignments
    CheckAssignmentDecorator.decorate_collection(object.check_assignments)
                            .sort_by { |a| (a.completion_date || Time.current) }
                            .reverse
  end

  def project_name
    object.project.name
  end

  def last_check_date
    if checked?
      "#{h.l(object.last_check_date)} (#{last_check_date_time_diff})"
    else
      "not checked yet"
    end
  end

  def checked?
    object.last_check_date.present?
  end

  def row_class
    if !enabled?
      "active"
    elsif object.last_check_date.nil?
      "warning"
    elsif days_to_deadline_as_number <= 0
      "danger"
    end
  end

  def css_disabled_state
    '<i class="glyphicon glyphicon-time"></i>'
  end

  def days_to_deadline_as_number
    to_date = object.last_check_date || object.created_at.to_date
    to_date += object.reminder.valid_for_n_days.days
    from_date = Time.zone.today
    (to_date - from_date).to_i
  end

  def days_to_deadline
    if !enabled?
      ""
    elsif overdue?
      "after deadline"
    else
      days_to_deadline_as_number
    end
  end

  def overdue?
    enabled? && days_to_deadline_as_number < 0
  end

  def status_text
    return "disabled" unless enabled?
    if overdue?
      "enabled_and_overdue"
    elsif !checked?
      "enabled_and_not_checked_yet"
    else
      "enabled"
    end
  end

  def last_checked_by
    object.last_check_user.name if object.last_check_user.present?
  end

  def review
    reminder_name
  end

  delegate :name, to: :reminder, prefix: true

  def assignments
    check_assignments.select { |c| c.object.completion_date.present? }
  end

  def has_appointed_review?
    return false if check_assignments.empty?
    check_assignments.first.completion_date.nil?
  end

  def current_reviewer_info
    return unless has_appointed_review?
    check_assignments.first.checker +
      reviewer_deadline(check_assignments.first.days_till_reviewer_deadline)
  end

  def slack_channel
    object.reminder.slack_channel || object.project.channel_name
  end

  def supervisor_slack_channel
    object.reminder.supervisor_slack_channel
  end

  def completion_notification_text(checker)
    "#{checker.name} has completed #{object.reminder.name} " \
      "in #{object.project.name}."
  end

  private

  def reviewer_deadline(days_left)
    if days_left.is_a?(Integer)
      " (planned in #{days_left} days)"
    else
      " (no deadline set)"
    end
  end

  def last_check_date_time_diff
    days_diff = (Time.zone.today - object.last_check_date).to_i
    case days_diff
    when 0 then "today"
    when 1 then "yesterday"
    else
      h.pluralize(days_diff, "day") + " ago"
    end
  end
end
