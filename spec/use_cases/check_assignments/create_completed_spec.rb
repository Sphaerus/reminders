require "rails_helper"

describe CheckAssignments::CreateCompleted do
  let(:service) { described_class.new(parameters) }
  let(:parameters) do
    {
      checker: checker,
      project_check: project_check,
      assignments_repository: repo,
      contact_person: create(:admin)
    }
  end
  let(:repo) { CheckAssignmentsRepository.new }
  let(:assignment) { repo.latest_assignment(project_check) }

  describe "#call" do
    let(:checker) { create(:user) }
    let(:project_check) { create(:project_check) }

    it "creates new assignment with completion date" do
      expect(repo.latest_assignment(project_check))
        .to be nil
      service.call
      expect(assignment).not_to be nil
      expect(assignment.completion_date).not_to be nil
    end
  end
end
