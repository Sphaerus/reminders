require "rails_helper"

describe ProjectCheckDecorator do
  let(:check) { ProjectCheck.new(reminder: reminder, project: project) }
  let(:reminder) { Reminder.new }
  let(:project) { Project.new(channel_name: "channel") }
  let(:decorator) { described_class.new(check) }

  describe "#last_check_date" do
    context "when there is no date" do
      it 'returns "not checked yet"' do
        check.last_check_date = nil
        expect(decorator.last_check_date).to eq "not checked yet"
      end
    end

    context "when the date is set" do
      before do
        Timecop.freeze(Time.zone.parse("2015-05-20"))
      end

      after do
        Timecop.return
      end

      it 'returns "date (X days ago)" for more than one day' do
        check.last_check_date = 2.days.ago.to_date
        expect(decorator.last_check_date).to eq "2015-05-18 (2 days ago)"
      end

      it 'returns "date (yesterday)" for one day ago' do
        check.last_check_date = Time.zone.yesterday
        expect(decorator.last_check_date).to eq "2015-05-19 (yesterday)"
      end

      it 'returns "date (today)" for today' do
        check.last_check_date = Time.zone.today
        expect(decorator.last_check_date).to eq "2015-05-20 (today)"
      end
    end
  end

  describe "#slack_channels" do
    let(:reminder) { Reminder.new }
    before { check.project.channel_name = "project-chan-1 project-chan-2" }

    context "when reminder has one slack_channel specified" do
      before { check.reminder.slack_channel = "some-channel" }

      it "returns slack_channels of reminder", focus: true do
        expect(decorator.slack_channels).to eq(%w(some-channel))
      end

      context "when notify projects channels is enabled" do
        before { check.reminder.notify_projects_channels = true }

        it "returns reminder and project channels" do
          expect(decorator.slack_channels).to eq(%w(some-channel project-chan-1 project-chan-2))
        end
      end

      context "when notify projects channels is disabled" do
        before { check.reminder.notify_projects_channels = false }

        it "returns reminder and project channels" do
          expect(decorator.slack_channels).to eq(%w(some-channel))
        end
      end
    end

    context "when reminder has 3 slack channels specified" do
      before { check.reminder.slack_channel = "chan1 chan2 chan3" }

      it "returns all 3 channels", focus: true do
        expect(decorator.slack_channels).to eq(%w(chan1 chan2 chan3))
      end
    end

    context "when reminder do not have slack_channel specified" do
      before { check.reminder.slack_channel = nil }

      context "when notify projects channels is enabled" do
        before { check.reminder.notify_projects_channels = true }

        it "returns slack channels of project" do
          expect(decorator.slack_channels).to eq(%w(project-chan-1 project-chan-2))
        end
      end

      context "when notify projects channels is disabled" do
        before { check.reminder.notify_projects_channels = false }

        it "returns slack channels of project" do
          expect(decorator.slack_channels).to eq(%w(project-chan-1 project-chan-2))
        end
      end
    end
  end

  describe "#status_text" do
    before do
      allow(decorator).to receive(:enabled?) { enabled }
      allow(decorator).to receive(:overdue?) { overdue }
      allow(decorator).to receive(:checked?) { checked }
    end

    subject { decorator.status_text }

    context "when project check is enabled" do
      let(:enabled) { true }
      let(:overdue) { false }
      let(:checked) { true }

      it { is_expected.to eq "enabled" }

      context "and overdue" do
        let(:overdue) { true }
        it { is_expected.to eq "enabled_and_overdue" }
      end

      context "and not checked yet" do
        let(:checked) { false }
        it { is_expected.to eq "enabled_and_not_checked_yet" }
      end
    end

    context "when project check is disabled" do
      let(:enabled) { false }
      it { is_expected.to eq "disabled" }
    end
  end

  describe "#days_to_deadline_as_number" do
    it "includes disabled period in the calculations" do
      reminder = create(:reminder, valid_for_n_days: 30)
      check = create(:project_check,
                     reminder: reminder,
                     last_check_date: 20.days.ago,
                     last_check_date_without_disabled_period: 10.days.ago)
      decorator = described_class.new(check)
      expect(decorator.days_to_deadline_as_number).to eq 20
    end
  end
end
