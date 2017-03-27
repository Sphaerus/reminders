require "rails_helper"

describe ProjectCheckedOnTimeJob do
  let(:job) { described_class.new(check.id, days_valid, daily_reminders) }
  let(:daily_reminders) { %w(1 2) }
  let(:days_valid) { 11 }
  let(:project_checks_repository) do
    repo = InMemoryRepository.new
    repo.all = [check]
    repo
  end

  describe "#perform" do
    let(:creation_time) { Time.current }
    let(:last_check_date) { nil }
    let(:check) do
      double(:project_check, id: 1, last_check_date: last_check_date,
                             created_at: creation_time,
                             last_check_date_without_disabled_period: nil)
    end

    before do
      job.project_checks_repository = project_checks_repository
    end

    after do
      job.perform
    end

    context "when check isn't overdue and has no notifications today" do
      let(:last_check_date) { 3.days.ago.to_date }

      it "doesn't call any of ovedue and notification day services" do
        expect(ProjectChecks::HandleOverdue).to_not receive(:new)
        expect(ProjectChecks::HandleNotificationDay).to_not receive(:new)
      end
    end

    context "when today is notification day" do
      let(:last_check_date) { 2.days.ago.to_date }
      it "check notification day service is called" do
        expect(ProjectChecks::HandleNotificationDay).to receive(:new)
          .with(check, 2) { double(call: true) }
      end
    end

    context "when check is overdue" do
      context "by last_check_date in the past" do
        let(:last_check_date) { (days_valid + 10).days.ago.to_date }

        it "check overdue service is called" do
          expect(ProjectChecks::HandleOverdue).to receive(:new)
            .with(check, 21) { double(call: true) }
        end
      end

      context "by creation date in the past" do
        let(:creation_time) { (days_valid + 1).days.ago }

        it "check overdue service is called" do
          expect(ProjectChecks::HandleOverdue).to receive(:new)
            .with(check, 12) { double(call: true) }
        end
      end
    end
  end
end
