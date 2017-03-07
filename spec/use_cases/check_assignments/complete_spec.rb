require "rails_helper"

describe CheckAssignments::Complete do
  let(:service) do
    described_class.new(
      assignment: assignment,
      checker: checker,
      project_check: project_check,
    )
  end
  let(:repo) { CheckAssignmentsRepository.new }

  describe "#call" do
    let(:user) { create(:user) }
    let(:checker) { create(:user) }
    let(:project_check) { create(:project_check, reminder: reminder) }
    let(:reminder) { create(:reminder) }
    let(:assignment) do
      create(:check_assignment, user: user,
                                project_check: project_check)
    end

    around do |example|
      previous = AppConfig["slack_enabled"]
      AppConfig["slack_enabled"] = "true"
      example.run
      AppConfig["slack_enabled"] = previous
    end

    it "adds completion date to assignment" do
      expect(assignment.completion_date).to be nil
      service.call
      expect(assignment.completion_date)
        .not_to be nil
    end

    it "adds note url to assignment if passed" do
      expect(assignment.note_url).to be nil
      service.call(note_url: "some url")
      expect(assignment.note_url)
        .to eq "some url"
    end

    it "it updates user performing check" do
      expect(assignment.user_id).to eq user.id
      service.call
      expect(assignment.user_id).to eq checker.id
    end

    it "updates project check" do
      expect(project_check.last_check_date).to be nil
      expect(project_check.last_check_user).to be nil
      service.call
      expect(project_check.last_check_date).to eq assignment.completion_date
      expect(project_check.last_check_user).to eq checker
    end

    it "does not notify slack" do
      service.call
      expect_any_instance_of(Notifier).not_to receive(:notify_slack)
    end

    context "supervisor_slack_channel is set on reminder" do
      let(:project_check) do
        create(:project_check, project: project, reminder: reminder)
      end
      let(:project) { create(:project, name: "The Project") }
      let(:reminder) do
        create(:reminder,
               supervisor_slack_channel: "supervisors",
               name: "Awesome review",
              )
      end

      it "notifies supervisor slack channel" do
        message = "Just letting you know that " \
                  "John Doe has completed Awesome review in The Project: " \
                  "http://example.com"
        expect_any_instance_of(Notifier).to receive(:notify_slack)
          .with(
            message,
            channel: 'supervisors',
          ).and_return({})
        service.call(note_url: "http://example.com")
      end
    end
  end
end
