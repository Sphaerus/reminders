class CheckAssignmentDecorator < BaseDecorator
  delegate :completion_date, :created_at, :id, :user_id, :project_check

  def checker
    object.user.name
  end

  # rubocop:disable Metrics/AbcSize
  def note_url
    if object.note_url.to_s =~ /http/
      h.link_to h.truncate(object.note_url.to_s, length: 40), object.note_url
    else
      object.note_url
    end
  end
  # rubocop:enable Metrics/AbcSize

  def row_class
    "active" if completion_date.present?
  end

  def days_till_reviewer_deadline
    (object.deadline - Time.current.to_date).to_i if object.deadline.present?
  end

  def assigned_days_ago_as_string
    "#{h.time_ago_in_words(object.created_at)} ago"
  end

  def completion_notification_text(checker)
    "#{checker.name} has completed #{object.project_check.reminder.name} " \
      "in #{object.project_check.project.name}: #{object.note_url}"
  end

  def project_name
    object.project_check.project.name
  end
end
