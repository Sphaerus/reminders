require "rails_helper"

describe CheckReminderJob do
  let(:job) { described_class.new }
  let(:reminder) do
    double(:reminder, id: 1, valid_for_n_days: days_valid,
                      remind_after_days: daily_reminders)
  end
  let(:daily_reminders) { [1, 2] }
  let(:days_valid) { 11 }
  let(:reminders_repository) do
    repo = InMemoryRepository.new
    repo.all = [reminder]
    repo
  end
  let(:check_1) { double(id: 21, enabled?: true, check_assignments: []) }
  let(:check_2) { double(id: 12, enabled?: true, check_assignments: []) }
  let(:check_3) { double(id: 12, enabled?: false, check_assignments: []) }
  let(:check_4) do
    double(id: 12, enabled?: false,
           check_assignments: [double(completion_date: nil)])
  end
  let(:project_checks_repository) do
    checks = [check_1, check_2, check_3, check_4]
    double(:project_checks_repository, for_reminder: checks)
  end

  describe "#perform" do
    before do
      job.reminders_repository = reminders_repository
      job.project_checks_repository = project_checks_repository
    end

    it "creates a job for each enabled check belonging to the reminder" do
      check_job = double(perform: true, check_assignments: [])
      expect(ProjectCheckedOnTimeJob).to receive(:new)
        .with(check_1.id)
        .and_return(check_job)
      expect(ProjectCheckedOnTimeJob).to receive(:new)
        .with(check_2.id)
        .and_return(check_job)
      expect(ProjectCheckedOnTimeJob).to_not receive(:new)
        .with(check_3.id)
      expect(ProjectCheckedOnTimeJob).to_not receive(:new)
        .with(check_4.id)

      job.perform reminder.id
    end
  end
end
