require "rails_helper"

describe CheckAssignments::ClearPending do
  let(:service) do
    described_class.new(
      project: project,
      assignments_repo: assignments_repo,
      project_checks_repo: project_checks_repo,
    )
  end
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:project_check) { create(:project_check, project: project) }
  let(:assignments_repo) { CheckAssignmentsRepository.new }
  let(:project_checks_repo) { ProjectChecksRepository.new }

  before do
    CheckAssignment.create(
      project_check: project_check,
      completion_date: nil,
      user: user,
    )
    CheckAssignment.create(
      project_check: project_check,
      completion_date: 2.days.ago,
      user: user,
    )
    CheckAssignment.create(
      project_check: project_check,
      completion_date: 3.weeks.ago,
      user: user,
    )
  end

  describe "#call" do
    it "removes pending assignments for a project leaving completed ones" do
      expect { service.call }
        .to change { assignments_repo.all.count }.by(-1)
    end
  end
end
