require "rails_helper"

describe ProjectChecks::OverrideDeadline do
  let(:service) do
    described_class.new(check: check, new_days_left: new_days_left)
  end
  let(:reminder) { create(:reminder, valid_for_n_days: valid_for_n_days) }
  let(:check) do
    create(:project_check, reminder: reminder, last_check_date: last_check_date)
  end

  let(:valid_for_n_days) { 10 }
  let(:new_days_left) { 20 }
  let(:last_check_date) { nil }

  subject { service.call }

  describe "#call" do
    context "when new days changed" do
      it "updates project check created_at_without_disabled_period field" do
        Timecop.freeze(Time.zone.today - valid_for_n_days.days) do
          expect { subject }.to change { check.created_at_without_disabled_period }
            .from(nil)
            .to(Time.current + 10.days)
        end
      end
    end

    context "when project is waiting for the first check" do
      it { is_expected.to eq true }
    end

    context "when project was aleady checked" do
      let(:new_days_left) { 100 }
      let(:last_check_date) { Time.zone.today }
      it { is_expected.to eq false }
    end
  end
end
