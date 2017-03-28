require "rails_helper"

describe ProjectCheckedOnTimeJob do
  let(:job) { described_class.new(check.id) }
  let(:init_daily_reminders) { %w(3 5) }
  let(:daily_reminders) { %w(1 2) }
  let(:project_checks_repository) do
    repo = InMemoryRepository.new
    repo.all = [check]
    repo
  end

  describe "#perform" do
    let(:creation_time) { Time.current }
    let(:last_check_date) { nil }
    let(:checked) { false }
    let(:reminder) do
      double(:reminder, id: 1,
             valid_for_n_days: 3,
             init_valid_for_n_days: 7,
             remind_after_days: daily_reminders,
             init_remind_after_days: init_daily_reminders)
    end
    let(:check) do
      double(:project_check,
             id: 1, last_check_date: last_check_date,
             created_at: creation_time, checked?: checked,
             last_check_date_without_disabled_period: nil,
             reminder: reminder)
    end

    before do
      job.project_checks_repository = project_checks_repository
    end

    after do
      job.perform
    end

    context "when project has not been checked yet" do
      let(:checked) { false }

      context "when check is overdue" do
        let(:creation_time) { (reminder.init_valid_for_n_days + 1).days.ago }

        it "check overdue service is called" do
          expect(ProjectChecks::HandleOverdue).to receive(:new)
                                                    .with(check, 8) { double(call: true) }
        end
      end

      context "when check isn't overdue and has no notifications today" do
        let(:last_check_date) { 4.days.ago.to_date }

        it "doesn't call any of ovedue and notification day services" do
          expect(ProjectChecks::HandleOverdue).to_not receive(:new)
          expect(ProjectChecks::HandleNotificationDay).to_not receive(:new)
        end
      end

      context "when today is notification day" do
        let(:last_check_date) { 3.days.ago.to_date }

        it "check notification day service is called" do
          expect(ProjectChecks::HandleNotificationDay).to receive(:new)
                                                            .with(check, 3) { double(call: true) }
        end
      end
    end

    context "when project has been checked before" do
      let(:checked) { true }

      context "when check is overdue" do
        let(:last_check_date) { (reminder.valid_for_n_days + 10).days.ago.to_date }
        let(:checked) { true }

        it "check overdue service is called" do
          expect(ProjectChecks::HandleOverdue).to receive(:new)
                                                    .with(check, 13) { double(call: true) }
        end
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
        let(:checked) { true }
        it "check notification day service is called" do
          expect(ProjectChecks::HandleNotificationDay).to receive(:new)
                                                            .with(check, 2) { double(call: true) }
        end
      end
    end
  end
end
