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
      def pending_for_project_check_ids(project_check_ids)
        all.select do |a|
          project_check_ids.include?(a.project_check_id) &&
            a.completion_date.nil?
        end
      end

      def delete_all(assignments)
        assignments.each { |a| delete(a) }
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
  before do
    assignments_repo.create(
      CheckAssignment.new(
        project_check: project_check,
        completion_date: nil,
        user: user,
      ),
    )
    assignments_repo.create(
      CheckAssignment.new(
        project_check: project_check,
        completion_date: 2.days.ago,
        user: user,
      ),
    )
    assignments_repo.create(
      CheckAssignment.new(
        project_check: project_check,
        completion_date: 3.weeks.ago,
        user: user,
      ),
    )
  end

  describe "#call" do
    it "removes pending assignments for a project leaving completed ones" do
      expect { service.call }
        .to change { assignments_repo.all.count }.by(-1)
    end
  end
end
