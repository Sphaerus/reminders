require "rails_helper"

describe ProjectChecksRepository do
  let(:repo) { described_class.new }

  describe "#all" do
    let(:project) { create(:project) }

    before do
      2.times { create(:project_check, project: project) }
    end

    it "returns all project checks" do
      expect(repo.all.count).to eq 2
    end

    it "returns each check with project" do
      expect(repo.all.first.project).to eq project
    end
  end

  describe "#for_reminder" do
    let(:reminder) { create(:reminder) }

    before do
      create(:project_check, reminder: reminder)
      create(:project_check)
    end

    it "returns all project checks for given reminder" do
      expect(repo.for_reminder(reminder).count).to eq 1
    end

    context "there are archived projects" do
      let(:archived_project) { create(:project, archived_at: Time.current) }
      let!(:project_check_with_archived_project) do
        create(:project_check, project: archived_project, reminder: reminder)
      end

      it "does not return project_checks with archived projects" do
        expect(repo.for_reminder(reminder))
          .to_not include(project_check_with_archived_project)
      end
    end
  end

  describe "#create" do
    let(:project) { create(:project) }
    let(:reminder) { create(:reminder) }

    let(:project_check) do
      ProjectCheck.new(
        project_id: project.id,
        reminder_id: reminder.id,
      )
    end

    it "creates new project check" do
      repo.create(project_check)
      expect(repo.all.count).to eq 1
    end
  end

  describe "#find" do
    let(:project_check) { create(:project_check) }
    let(:id) { project_check.id }

    it "returns project check with given id" do
      expect(repo.find(id)).to eq project_check
    end
  end

  describe "#update" do
    let(:project_check) { create(:project_check) }

    it "updates given project check" do
      expect(project_check.last_check_user_id).to be nil
      repo.update(project_check, last_check_user_id: 2)
      expect(repo.all.first.last_check_user_id).to eq 2
    end
  end
end
