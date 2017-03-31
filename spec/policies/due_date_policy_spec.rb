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

  shared_context "check disabled for duration" do |duration|
    before do
      repo = ProjectChecksRepository.new
      repo.update(check, enabled: false)
      check.update disabled_date: duration.ago
      repo.update(check, enabled: true)
      check
    end
  end

  shared_examples "due date is in the past/the future/today" do |date_diff, stuff|
    before do
      allow(policy).to receive(:due_on).and_return(due_on_date)
    end

    context "when due date is in the future" do
      let(:due_on_date) { date_diff.from_now.to_date }

      it "returns the difference between today and due date in days" do
        is_expected.to eq stuff[:future]
      end
    end

    context "when due date is in the past" do
      let(:due_on_date) { date_diff.ago.to_date }

      it "returns the negative difference between today and due date in days" do
        is_expected.to eq stuff[:past]
      end
    end

    context "when due date is today" do
      let(:due_on_date) { Time.zone.today.to_date }

      it { is_expected.to eq stuff[:today] }
    end
  end

  it { is_expected.to respond_to(:project_check) }

  describe "#due_on" do
    subject { policy.send :due_on }

    context "when configured to be valid for 60 days" do
      let(:valid_for_n_days) { 60 }

      context "and was checked 70 days ago" do
        let!(:check) { create(:project_check, last_check_date: 70.days.ago, reminder: reminder) }

        it { is_expected.to eq(10.days.ago.to_date) }

        context "and was disabled for 20 days" do
          include_context "check disabled for duration", 20.days

          it { is_expected.to eq(10.days.from_now.to_date) }
        end
      end
    end

    context "when configured to be first checked within 10 days" do
      let(:init_valid_for_n_days) { 10 }

      context "and was created 15 days ago and never checked" do
        let!(:check) { create(:project_check, created_at: 15.days.ago, reminder: reminder) }

        it { is_expected.to eq(5.days.ago.to_date) }

        context "and was disabled for 7 days" do
          include_context "check disabled for duration", 7.days

          it { is_expected.to eq(2.days.from_now.to_date) }
        end
      end
    end
  end

  describe "#due_in" do
    subject { policy.due_in }
    include_examples "due date is in the past/the future/today",
                     20.days,
                     future: 20,
                     past: -20,
                     today: 0
  end

  describe "#overdue?" do
    subject { policy.overdue? }
    include_examples "due date is in the past/the future/today",
                     20.days,
                     future: false,
                     past: true,
                     today: false
  end

  describe "#remind_on" do
    subject { policy.send :remind_on }
    let(:remind_after_days) { [5, 30, 45] }
    let(:init_remind_after_days) { [2, 6, 8] }

    context "when never checked" do
      let!(:check) { create(:project_check, created_at: 4.days.ago, reminder: reminder) }

      it "calculates notification dates from created_at" do
        is_expected.to eq([2.days.ago,
                           2.days.from_now,
                           4.days.from_now].map(&:to_date))
      end
    end

    context "when checked before" do
      let!(:check) { create(:project_check, last_check_date: 30.days.ago, reminder: reminder) }

      it "calculates notification dates from last_check_date" do
        expect(subject).to eq([25.days.ago,
                               Time.zone.today,
                               15.days.from_now].map(&:to_date))
      end
    end

    context "when disabled for a period of time" do
      let!(:check) { create(:project_check, last_check_date: 40.days.ago, reminder: reminder) }
      include_context "check disabled for duration", 10.days

      it "includes the disabled period in calculations" do
        expect(subject).to eq([25.days.ago,
                               Time.zone.today,
                               15.days.from_now].map(&:to_date))
      end
    end
  end

  describe "#remind_on?" do
    before do
      allow(policy).to receive(:remind_on)
        .and_return([5.days.from_now.to_date, 15.days.from_now.to_date])
    end

    context "if reminder should be sent on given date" do
      subject { policy.send(:remind_on?, 5.days.from_now) }

      it { is_expected.to be true }
    end

    context "if reminder shouldn't be sent on given date" do
      subject { policy.send(:remind_on?, 10.days.from_now) }

      it { is_expected.to be false }
    end
  end

  describe "#remind_today?" do
    subject { policy.remind_today? }
    before do
      allow(policy).to receive(:remind_on)
        .and_return(remind_on_dates)
    end

    context "if reminder should be sent today" do
      let(:remind_on_dates) { [Time.zone.today.to_date] }

      it { is_expected.to be true }
    end

    context "if reminder shouldn't be sent today" do
      let(:remind_on_dates) { [10.days.from_now.to_date] }

      it { is_expected.to be false }
    end
  end

  describe "#elapsed_days" do
    subject { policy.elapsed_days }

    context "when never checked" do
      let(:check) { create_check(created_at: 40.days.ago) }
      let!(:check) { create(:project_check, created_at: 40.days.ago, reminder: reminder) }

      it "calculates how many days have passed since created" do
        expect(subject).to eq(40)
      end
    end

    context "when checked before" do
      let!(:check) { create(:project_check, last_check_date: 30.days.ago, reminder: reminder) }

      it "calculates how many days have passed since last check" do
        expect(subject).to eq(30)
      end

      context "and disabled for a period of time" do
        include_context "check disabled for duration", 10.days

        it "it includes the disabled period in calculations" do
          expect(subject).to eq(20)
        end
      end
    end
  end
end
