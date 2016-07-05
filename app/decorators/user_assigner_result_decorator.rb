class UserAssignerResultDecorator < BaseDecorator
  def id
    result[:user].id
  end

  def name
    result[:user].name
  end

  def result
    object
  end

  def summary
    "#{result[:total_checks_count]}"\
     " (#{result[:completed_checks_count]} completed)"
  end

  def rating
    result[:wannado_rating]
  end

  def last_check_date
    result[:last_check_date]
  end
end
