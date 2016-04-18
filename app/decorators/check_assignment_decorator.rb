class CheckAssignmentDecorator < Draper::Decorator
  delegate :completion_date, :created_at, :id

  def checker
    object.user.name
  end

  def note_url
    if object.note_url.to_s =~ /http/
      h.link_to h.truncate(object.note_url.to_s, length: 80), object.note_url
    else
      object.note_url
    end
  end

  def row_class
    "active" if completion_date.present?
  end

  def days_till_reviewer_deadline
    (object.deadline - Time.current.to_date).to_i if object.deadline.present?
  end

  def assigned_days_ago_as_string
    "#{h.time_ago_in_words(object.created_at)} ago"
  end
end
