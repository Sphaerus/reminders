require "rails_helper"

describe DueDatePolicy do
  subject { policy }
  let(:policy) { described_class.new(check) }
  let(:reminder) do
    create(:reminder,
           valid_for_n_days: valid_for_n_days,
           remind_after_days: remind_after_days,
           init_valid_for_n_days: init_valid_for_n_days,
           init_remind_after_days: init_remind_after_days)
  end
  let(:check) { create(:project_check, reminder: reminder) }
  let(:valid_for_n_days) { 90 }
  let(:remind_after_days) { [30, 60, 85] }
  let(:init_valid_for_n_days) { 10 }
  let(:init_remind_after_days) { [5, 8] }

  def create_check(attrs = {})
    create(:project_check, attrs.merge(reminder: reminder))
  end

  def disable_check_for(duration)
    repo = ProjectChecksRepository.new
    repo.update(check, enabled: false)
    check.update disabled_date: duration.ago
    repo.update(check, enabled: true)
    check
  end

  it { is_expected.to respond_to(:project_check) }

  describe "#due_on" do
    subject { policy.due_on }

    context "when configured to be valid for 60 days" do
      let(:valid_for_n_days) { 60 }

      context "and was checked 70 days ago" do
        let(:check) { create_check(last_check_date: 70.days.ago) }

        it { is_expected.to eq(10.days.ago.to_date) }

        context "and was disabled for 20 days" do
          before { disable_check_for(20.days) }

          it { is_expected.to eq(10.days.from_now.to_date) }
        end
      end
    end

    context "when configured to be first checked within 10 days" do
      let(:init_valid_for_n_days) { 10 }

      context "and was created 15 days ago and never checked" do
        let(:check) { create_check(created_at: 15.days.ago) }

        it { is_expected.to eq(5.days.ago.to_date) }

        context "and was disabled for 7 days" do
          before { disable_check_for(7.days) }

          it { is_expected.to eq(2.days.from_now.to_date) }
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
    subject { policy.remind_on }
    let(:remind_after_days) { [5, 30, 45] }
    let(:init_remind_after_days) { [2, 6, 8] }

    context "when never checked" do
      let(:check) { create_check(created_at: 4.days.ago) }

      it "calculates notification dates from created_at" do
        expect(subject).to eq([2.days.ago,
                               2.days.from_now,
                               4.days.from_now].map(&:to_date))
      end
    end

    context "when checked before" do
      let(:check) { create_check(last_check_date: 30.days.ago) }

      it "calculates notification dates from last_check_date" do
        expect(subject).to eq([25.days.ago,
                               Time.zone.today,
                               15.days.from_now].map(&:to_date))
      end
    end

    context "when disabled for a period of time" do
      let(:check) { create_check(last_check_date: 40.days.ago) }
      before { disable_check_for(10.days) }

      it "includes the disabled period in calculations" do
        expect(subject).to eq([25.days.ago,
                               Time.zone.today,
                               15.days.from_now].map(&:to_date))
      end
    end
  end

  describe "#remind_on?" do
    it "checks if a reminder should be sent on given date" do
      allow(subject).to receive(:remind_on)
        .and_return([5.days.from_now.to_date, 15.days.from_now.to_date])

      expect(subject.remind_on?(5.days.from_now)).to eq true
      expect(subject.remind_on?(10.days.from_now)).to eq false
    end
  end

  describe "#remind_today?" do
    context "if reminder should be sent today" do
      it "returns true" do
        allow(subject).to receive(:remind_on)
          .and_return([Time.zone.today.to_date])

        expect(subject.remind_today?).to eq true
      end
    end

    context "if reminder shouldn't be sent today" do
      it "returns true" do
        allow(subject).to receive(:remind_on)
          .and_return([10.days.from_now.to_date])

        expect(subject.remind_today?).to eq false
      end
    end
  end

  describe "#elapsed_days" do
    subject { policy.elapsed_days }

    context "when never checked" do
      let(:check) { create_check(created_at: 40.days.ago) }

      it "calculates how many days have passed since created" do
        expect(subject).to eq(40)
      end
    end

    context "when checked before" do
      let(:check) { create_check(last_check_date: 30.days.ago) }

      it "calculates how many days have passed since last check" do
        expect(subject).to eq(30)
      end
    end

    context "when disabled for a period of time" do
      let(:check) { create_check(last_check_date: 30.days.ago) }
      before { disable_check_for(10.days) }

      it "it includes the disabled period in calculations" do
        expect(subject).to eq(20)
      end
    end
  end
end
