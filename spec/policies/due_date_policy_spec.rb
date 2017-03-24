require "rails_helper"

describe DueDatePolicy do
  subject { described_class.new(check) }
  let(:check) { create(:project_check) }

  def create_check(attrs = {})
    create(:project_check, attrs.merge(reminder: reminder))
  end

  def disable_check_for(duration)
    repo = ProjectChecksRepository.new
    repo.update(check, enabled: false)
    check.update disabled_date: duration.ago
    repo.update(check, enabled: true)
    return check
  end

  it { is_expected.to respond_to(:project_check) }
  it { is_expected.to delegate_method(:reminder).to(:project_check) }

  describe "#due_on" do
    context "when configured to be valid for 60 days" do
      subject { described_class.new(check).due_on }
      let(:reminder) { create(:reminder, valid_for_n_days: 60) }

      context "and was checked 70 days ago" do
        let(:check) { create_check(last_check_date: 70.days.ago) }

        it { is_expected.to eq(10.days.ago.to_date) }

        context "and was disabled for 20 days" do
          before { disable_check_for(20.days) }

          it { is_expected.to eq(10.days.from_now.to_date) }
        end
      end

      context "and was created 70 days ago and never checked" do
        let(:check) { create_check(created_at: 70.days.ago) }

        it { is_expected.to eq(10.days.ago.to_date) }

        context "and was disabled for 20 days" do
          before { disable_check_for(20.days) }

          it { is_expected.to eq(10.days.from_now.to_date) }
        end
      end
    end
  end

  describe "#due_in" do
    it "returns the difference between today and due date in days" do
      allow(subject).to receive(:due_on).and_return(20.days.from_now.to_date)
      expect(subject.due_in).to eq 20
    end

    it "is less than zero when overdue" do
      allow(subject).to receive(:due_on).and_return(20.days.ago.to_date)
      expect(subject.due_in).to eq(-20)
    end

    it "equals zero if due today" do
      allow(subject).to receive(:due_on).and_return(Time.zone.today.to_date)
      expect(subject.due_in).to eq(0)
    end
  end

  describe "#overdue?" do
    it "is true if due date is in the past" do
      allow(subject).to receive(:due_on).and_return(20.days.ago.to_date)
      expect(subject.overdue?).to eq(true)
    end

    it "is false if due date is in the future" do
      allow(subject).to receive(:due_on).and_return(20.days.from_now.to_date)
      expect(subject.overdue?).to eq(false)
    end

    it "is false if due today" do
      allow(subject).to receive(:due_on).and_return(Time.zone.today.to_date)
      expect(subject.overdue?).to eq(false)
    end
  end

  describe "#remind_on" do
    subject { described_class.new(check).remind_on }
    let(:reminder) { create(:reminder, remind_after_days: [5, 30, 45]) }

    context "when never checked" do
      let(:check) { create_check(created_at: 40.days.ago) }

      it "calculates notification dates from created_at" do
        expect(subject).to eq([35.days.ago,
                               10.days.ago,
                               5.days.from_now,].map(&:to_date))
      end
    end

    context "when checked before" do
      let(:check) { create_check(last_check_date: 30.days.ago) }

      it "calculates notification dates from last_check_date" do
        expect(subject).to eq([25.days.ago,
                               Time.zone.today,
                               15.days.from_now,].map(&:to_date))
      end
    end

    context "when disabled for a period of time" do
      let(:check) { create_check(last_check_date: 40.days.ago) }
      before { disable_check_for(10.days) }

      it "includes the disabled period in calculations" do
        expect(subject).to eq([25.days.ago,
                               Time.zone.today,
                               15.days.from_now,].map(&:to_date))
      end
    end
  end
end
