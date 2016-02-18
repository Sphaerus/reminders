require "rails_helper"

describe CheckAssignmentsRepository do
  let(:repo) { described_class.new }
  let(:project_check) { create(:project_check) }

  describe "#latest_assignment" do
    let!(:monday_assignment) do
      create(:check_assignment,
             project_check: project_check,
             user: create(:user),
             completion_date: 7.days.ago,
            )
    end
    let!(:wednesday_assignment) do
      create(:check_assignment,
             project_check: project_check,
             user: create(:user),
             completion_date: 5.days.ago,
            )
    end
    let!(:fresh_assignment) do
      create(:check_assignment,
             project_check: project_check,
             user: create(:user),
            )
    end

    it "returns latest check assignment" do
      expect(repo.latest_assignment(project_check)).to eq fresh_assignment
    end

    context "completed: true" do
      it "returns latest completed check assignment" do
        expect(
          repo.latest_assignment(project_check,
                                 completed: true),
        ).to eq wednesday_assignment
      end
    end
  end

  describe "#add" do
    let(:parameters) { { project_check: project_check, user: create(:user) } }

    it "creates new check_assignment" do
      expect(repo.latest_assignment(project_check)).to be nil
      repo.add(parameters)
      expect(repo.latest_assignment(project_check))
        .to be_an_instance_of CheckAssignment
    end
  end

  describe "#update" do
    let(:user) { create(:user) }
    let(:check_assignment) do
      create(:check_assignment, project_check: project_check,
                                user: create(:user))
    end

    it "updates given check assignment" do
      expect do
        repo.update(check_assignment, user_id: user.id)
      end.to change { check_assignment.user_id }.to user.id
    end
  end

  describe "#latest_user_assignments" do
    let(:user) { create(:user) }
    let(:assignments) { repo.latest_user_assignments(user_id: user.id) }

    before do
      create(:check_assignment, user: user, completion_date: 1.day.ago)
      3.times { create(:check_assignment, user: user) }
      create(:check_assignment, user: user, completion_date: 2.days.ago)
    end

    it "returns latest assignments" do
      expect(assignments.count).to eq(5)
    end

    it "returns firstly assignments without completion_date" do
      assignments.take(3).each do |assignment|
        expect(assignment.completion_date).to be_nil
      end
    end

    it "returns assignments with completion_date on the end" do
      assignments.last(2).each do |assignment|
        expect(assignment.completion_date).to_not be_nil
      end
    end

    context "with limit passed" do
      let(:assignments) do
        repo.latest_user_assignments(user_id: user.id, limit: 1)
      end

      it "returns limited assignments" do
        expect(assignments.count).to eq(1)
      end
    end
  end

  describe "#find" do
    let(:assignment) { create(:check_assignment, user: create(:user)) }
    let(:id) { assignment.id }

    it "returns assignment with given id" do
      expect(repo.find(id)).to eq assignment
    end
  end
end
