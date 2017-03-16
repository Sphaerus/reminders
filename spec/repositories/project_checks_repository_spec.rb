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
    let(:project_check) do
      create(:project_check,
             last_check_date: 3.weeks.ago,
             enabled: false,
             disabled_date: 1.week.ago)
    end

    it "updates given project check" do
      expect(project_check.last_check_user_id).to be nil
      repo.update(project_check, last_check_user_id: 2)
      expect(repo.all.first.last_check_user_id).to eq 2
    end
    context "when you set enabled to true" do
      before { repo.update(project_check, enabled: true) }
      it "fill :last_check_date_without_disabled_period" do
        expect(project_check.last_check_date_without_disabled_period)
          .to eq(2.weeks.ago.to_date)
      end
      it "set :disabled_date to nil" do
        expect(project_check.disabled_date).to eq(nil)
      end
    end

    context "when you set enabled to false" do
      before { repo.update(project_check, enabled: false) }
      it "set :disabled_date to Date.today" do
        expect(project_check.disabled_date).to eq(Time.zone.today)
      end
    end
  end

  describe "#ids_for_project" do
    let(:tested_project) { create(:project) }
    let(:different_project) { create(:project) }
    let!(:check_for_tested_project) do
      create(:project_check, project: tested_project)
    end
    let!(:another_check_for_tested_project) do
      create(:project_check, project: tested_project)
    end
    let!(:check_for_different_project) do
      create(:project_check, project: different_project)
    end

    it "returns ids of project checks for a given project" do
      expect(repo.ids_for_project(tested_project))
        .to match_array(
          [check_for_tested_project.id, another_check_for_tested_project.id],
        )
    end
  end

  describe "#requiring_jira_issues" do
    subject { described_class.new.requiring_jira_issues }

    let(:reminder) { create(:reminder, valid_for_n_days: 30, jira_issue_lead: 7) }

    let(:project_1) { create(:project) }
    let!(:project_1_check) do
      create(:project_check, project: project_1, reminder: reminder)
    end

    let(:project_2) { create(:project) }

    let(:project_3) { create(:project) }
    let!(:project_3_check) do
      create(:project_check, project: project_3, reminder: reminder)
    end

    context "when jira issue is already created" do
      let(:last_check_date) { Time.zone.today - 1.year }
      let!(:project_2_check) do
        create(:project_check,
               project: project_2,
               reminder: reminder,
               jira_issue_key: "RD-1",
               last_check_date: last_check_date)
      end

      it "returns no project checks" do
        expect(subject).to eq([])
      end
    end

    context "when project check is disabled" do
      let(:last_check_date) { Time.zone.today - 1.year }
      let!(:project_2_check) do
        create(:project_check,
               project: project_2,
               reminder: reminder,
               last_check_date: last_check_date,
               enabled: false)
      end

      it "returns no project checks" do
        expect(subject).to eq([])
      end
    end

    context "when there is one check with 7 days to next check" do
      let(:jira_issue_lead) { 7 }
      let(:reminder) { create(:reminder, valid_for_n_days: 30, jira_issue_lead: jira_issue_lead) }
      let(:last_check_date) { Time.zone.today - 23.days }

      context "when project check was previously checked" do
        let!(:project_2_check) do
          create(:project_check,
                 project: project_2,
                 reminder: reminder,
                 last_check_date: last_check_date)
        end

        context "when jira issue should be created 7 days before next check" do
          it "returns 1 projeck check" do
            expect(subject.count).to eq(1)
            expect(subject.first).to eq(project_2_check)
          end
        end

        context "when jira issue should be created 6 days before next check" do
          let(:jira_issue_lead) { 6 }

          it "returns no project checks" do
            expect(subject).to eq([])
          end
        end

        context "when jira issue should be created 8 days before next check" do
          let(:jira_issue_lead) { 8 }

          it "returns 1 projeck check" do
            expect(subject.count).to eq(1)
            expect(subject.first).to eq(project_2_check)
          end
        end

        context "when reminder has blank jira_issue_lead" do
          let(:jira_issue_lead) { nil }
          it "returns no project checks" do
            expect(subject).to eq([])
          end
        end
      end

      context "when project check was never checked before" do
        let!(:project_2_check) do
          create(:project_check,
                 project: project_2,
                 reminder: reminder,
                 last_check_date: nil,
                 created_at: Time.zone.now - 23.days)
        end

        context "when jira issue should be created 7 days before next check" do
          it "returns 1 projeck check" do
            expect(subject.count).to eq(1)
            expect(subject.first).to eq(project_2_check)
          end
        end

        context "when jira issue should be created 6 days before next check" do
          let(:jira_issue_lead) { 6 }

          it "returns no project checks" do
            expect(subject).to eq([])
          end
        end

        context "when jira issue should be created 8 days before next check" do
          let(:jira_issue_lead) { 8 }

          it "returns 1 projeck check" do
            expect(subject.count).to eq(1)
            expect(subject.first).to eq(project_2_check)
          end
        end

        context "when reminder has blank jira_issue_lead" do
          let(:jira_issue_lead) { nil }
          it "returns no project checks" do
            expect(subject).to eq([])
          end
        end
      end
    end
  end
end
