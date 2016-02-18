class UserAssigner
  attr_accessor :reminder, :users_with_skill, :check_assignments_repo,
                :last_checker

  def initialize(reminder, users_with_skill, last_checker,
                 check_assignments_repo: nil)
    self.reminder = reminder
    self.users_with_skill = users_with_skill
    self.check_assignments_repo = check_assignments_repo ||
                                  CheckAssignmentsRepository.new
    self.last_checker = last_checker
  end

  def results
    output = check_assignments_repo
             .from_last_n_days_for_users(30, user_with_skill_ids)
             .group_by(&:user_id)
    user_ids_without_assignments(output.keys).each do |id|
      output[id] = []
    end
    output.map { |user_id, checks| build_output_structure(user_id, checks) }
          .sort_by { |result| result[:wannado_rating] }
  end

  private

  def user_with_skill_ids
    users_with_skill.map(&:id)
  end

  def user_ids_without_assignments(user_with_assignments_ids)
    user_with_skill_ids - user_with_assignments_ids
  end

  def build_output_structure(user_id, checks)
    completed = checks.select { |check| check.completion_date.present? }
    result = {
      user: users_with_skill.find { |u| u.id == user_id },
      total_checks_count: checks.count,
      completed_checks_count: completed.count,
      last_check_date: completed.last.try(:completion_date)
    }
    result[:wannado_rating] = wannado_rating(result)
    result
  end

  def wannado_rating(result)
    rating = result[:total_checks_count] +
             result[:completed_checks_count] * 0.5
    rating += 2 if last_checker == result[:user]
    rating
  end
end
