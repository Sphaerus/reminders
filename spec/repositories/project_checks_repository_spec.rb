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
    include_context "time frozen"

    it "updates given project check" do
      expect(project_check.last_check_user_id).to be nil
      repo.update(project_check, last_check_user_id: 2)
      expect(repo.all.first.last_check_user_id).to eq 2
    end

    context "given a disabled project check" do
      let(:attrs) { {} }
      let(:project_check) { create(:project_check, attrs) }

      shared_examples "setting enabled to true" do
        context "when you set enabled to true" do
          before do
            repo.update(project_check, enabled: true)
          end

          it "calculates the last_check_date_without_disabled_period" do
            expect(project_check.last_check_date_without_disabled_period)
              .to eq(expected_last_check_date_without_disabled_period.try(:to_date))
          end

          it "calculates the created_at_without_disabled_period" do
            expect(project_check.created_at_without_disabled_period)
              .to eq(expected_created_at_without_disabled_period.try(:to_datetime))
          end

          it "sets disabled_date to nil" do
            expect(project_check.disabled_date).to eq(nil)
          end
        end
      end

      context "that was checked before" do
        let(:attrs) do
          { disabled_date: 2.weeks.ago,
            enabled: false,
            last_check_date: 3.weeks.ago }
        end
        let(:expected_last_check_date_without_disabled_period) { 1.week.ago }
        let(:expected_created_at_without_disabled_period) { nil }

        include_examples "setting enabled to true"
      end

      context "that was disabled and enabled before" do
        let(:attrs) do
          { last_check_date: 5.weeks.ago,
            last_check_date_without_disabled_period: 4.weeks.ago,
            disabled_date: 1.week.ago,
            enabled: false }
        end
        let(:expected_last_check_date_without_disabled_period) { 3.weeks.ago }
        let(:expected_created_at_without_disabled_period) { nil }

        include_examples "setting enabled to true"
      end

      context "that was never checked" do
        let(:attrs) do
          { created_at: 3.weeks.ago,
            disabled_date: 1.week.ago,
            enabled: false }
        end
        let(:expected_last_check_date_without_disabled_period) { nil }
        let(:expected_created_at_without_disabled_period) { 2.weeks.ago }

        include_examples "setting enabled to true"
      end

      context "that was never checked and disabled before" do
        let(:attrs) do
          { created_at: 4.weeks.ago,
            created_at_without_disabled_period: 3.weeks.ago,
            disabled_date: 1.week.ago,
            enabled: false }
        end
        let(:expected_last_check_date_without_disabled_period) { nil }
        let(:expected_created_at_without_disabled_period) { 2.weeks.ago }

        include_examples "setting enabled to true"
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
end
