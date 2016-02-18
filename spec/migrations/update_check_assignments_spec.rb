require "rails_helper"
require File.join(Rails.root,
                  "db",
                  "migrate",
                  "20150609115359_update_check_assignments")

describe UpdateCheckAssignments do
  let(:migration) { described_class.new }
  let(:user) { create(:user) }

  describe "#up" do
    context "when project check has last check date and user" do
      before do
        create(:project_check,
               last_check_user_id: user.id, last_check_date: "2015-05-06")
        create(:project_check,
               last_check_user_id: user.id, last_check_date: "2015-05-09")
      end

      it "creates check assignment" do
        migration.up
        expect(CheckAssignment.count).to eq 2
      end
    end

    context "when project check doesn't have check date or user" do
      before do
        create(:project_check)
        create(:project_check, last_check_user_id: user.id)
        create(:project_check, last_check_date: "2015-05-09")
      end

      it "skips creating check assignment" do
        migration.up
        expect(CheckAssignment.count).to eq 0
      end
    end
  end

  describe "#down" do
    context "when project check has no check assignments" do
      let!(:project_check) do
        create(:project_check, last_check_date: "2015-06-09")
      end

      it "doesn't update project check" do
        migration.down
        expect(project_check.last_check_date.to_s).to eq "2015-06-09"
      end
    end

    context "when project check has check assignment" do
      let(:project_check) { create(:project_check) }
      let!(:check_assignment1) do
        create(:check_assignment,
               user_id: user.id,
               completion_date: "2015-01-01".to_date,
               project_check_id: project_check.id,
              )
      end
      let!(:check_assignment2) do
        create(:check_assignment,
               user_id: user.id,
               completion_date: "2015-02-02".to_date,
               project_check_id: project_check.id,
              )
      end

      it "updates project check" do
        expect(project_check.last_check_date).to be nil
        expect(project_check.check_assignments.count).to eq 2
        expect(project_check.check_assignments.first).not_to be nil

        migration.down

        project_check = ProjectCheck.first

        expect(project_check.last_check_date).to eq "2015-02-02".to_date
        expect(project_check.last_check_user_id).to eq user.id
        expect(project_check.check_assignments.count).to eq 0
      end

      it "deletes all check assingments" do
        expect(CheckAssignment.count).to eq 2
        migration.down
        expect(CheckAssignment.count).to eq 0
      end
    end
  end
end
