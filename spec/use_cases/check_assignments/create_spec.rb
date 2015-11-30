require "rails_helper"

describe CheckAssignments::Create do
  let(:service) { described_class.new(parameters) }
  let(:parameters) do
    {
      assignments_repository: assignments_repo,
      checker: checker,
      project_check: project_check,
      contact_person: create(:admin),
    }
  end
  let(:assignments_repo) { CheckAssignmentsRepository.new }

  describe "#call" do
    let(:checker) { create(:user) }
    let(:project_check) { create(:project_check) }

    it "creates new check assignment" do
      service.call
      expect(assignments_repo.latest_assignment(project_check))
        .not_to be nil
    end

    it "returns new check assignment" do
      expect(service.call).to be_an_instance_of CheckAssignment
    end
  end
end
