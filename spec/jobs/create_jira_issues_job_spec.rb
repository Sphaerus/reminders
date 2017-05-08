require "rails_helper"

describe CreateJiraIssuesJob do
  let(:job) { described_class.new }

  describe ".perform" do
    it "creates instance and calls perform method" do
      expect_any_instance_of(described_class).to receive(:perform)
      expect(described_class).to receive(:new).with(no_args).and_return(job)
      described_class.perform
    end
  end

  describe "#perform" do
    subject { job.perform }

    context "when there are no projects needing jira issue" do
      before do
        expect_any_instance_of(
          ProjectChecksRepository,
        ).to receive(:requiring_jira_issues).with(no_args).and_return([])
      end

      it "does not create any jira issue" do
        expect(Jira).not_to receive(:create_issue_from_project)
        expect(subject).to eq([])
      end
    end

    context "when there is 1 project check requiring jira issue" do
      let(:project) { double :project, name: "Project 1" }
      let(:reminder) { double :reminder, jira_project_key: "RDM"}
      let(:project_check) { double :project_check, id: 3, project: project, reminder: reminder }
      let(:zone) { ActiveSupport::TimeZone.new("Kuwait") }
      let(:time) { zone.now }

      before do
        expect_any_instance_of(
          ProjectChecksRepository,
        ).to receive(:requiring_jira_issues).with(no_args).and_return([project_check])
      end

      it "creates 1 jira issue" do
        expect(Jira).to receive(:create_issue_from_project).once.with(project: project, reminder: reminder)
        expect(subject).to eq([project_check])
      end

      it "updates jira_issue_key and jira_issue_created_at" do
        expect(Time).to receive(:zone).and_return(zone)
        expect(zone).to receive(:now).and_return(time)
        expect(Jira).to receive(:create_issue_from_project)
          .once.with(project: project, reminder: reminder).and_return("key" => "RD-X")
        expect(project_check).to receive(:update_columns)
          .with(jira_issue_key: "RD-X", jira_issue_created_at: time)
        expect(subject).to eq([project_check])
      end
    end
  end
end
