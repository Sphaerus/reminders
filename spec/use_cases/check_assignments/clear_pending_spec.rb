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
  let(:assignments_repo) do
    class InMemoryAssignmentsRepository < InMemoryRepository
      def all
        CheckAssignment.all
      end

      def pending_for_project_check_ids(project_check_ids)
        CheckAssignment.all.where(
          project_check_id: project_check_ids,
          completion_date: nil,
        )
      end

      def delete_all(assignments)
        assignments.delete_all
      end
    end
    InMemoryAssignmentsRepository.new
  end
  let(:project_checks_repo) do
    class InMemoryProjectChecksRepository < InMemoryRepository
      def ids_for_project(project)
        project.project_checks.ids
      end
    end
    InMemoryProjectChecksRepository.new
  end
  let!(:not_completed_assignment) do
    create(:check_assignment,
           project_check: project_check,
           completion_date: nil,
           user: user)
  end
  let!(:completed_assignment) do
    create(:check_assignment,
           project_check: project_check,
           completion_date: 2.days.ago,
           user: user)
  end
  let!(:another_completed_assignment) do
    create(:check_assignment,
           project_check: project_check,
           completion_date: 3.weeks.ago,
           user: user)
  end

  describe "#call" do
    it "removes pending assignments for a project leaving completed ones" do
      service.call
      expect(assignments_repo.all).to_not include(not_completed_assignment)
      expect(assignments_repo.all).to include(completed_assignment)
      expect(assignments_repo.all).to include(another_completed_assignment)
    end
  end
end
