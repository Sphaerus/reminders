module ProjectChecks
  class OverrideDeadline
    attr_reader :check, :checks_repo, :new_days_left
    private :check, :checks_repo, :new_days_left

    def initialize(check:, new_days_left:, project_checks_repository: nil)
      @check = check
      @new_days_left = new_days_left.to_i
      @checks_repo = project_checks_repository || ProjectChecksRepository.new
    end

    def call
      return false unless allow_override?
      attrs = {
        created_at_without_disabled_period: calc_new_created_at,
      }
      checks_repo.update(check, attrs)
    end

    private

    def calc_new_created_at
      Time.current + (new_days_left - check.reminder.valid_for_n_days).days
    end

    def allow_override?
      check.last_check_date.nil?
    end
  end
end
