require "rails_helper"

describe ProjectChecks::RequiringJiraIssuesQuery do
  let(:repo) { described_class.new }

  describe "#all" do
    subject { described_class.new.all }

    let(:reminder) do
      create(:reminder,
             init_valid_for_n_days: 10,
             valid_for_n_days: 30,
             jira_issue_lead: jira_issue_lead)
    end
    let(:jira_issue_lead) { 7 }

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

      it_behaves_like "no project checks"
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

      it_behaves_like "no project checks"
    end

    context "when there is one check with 7 days to next check" do
      let(:jira_issue_lead) { 7 }
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

          it_behaves_like "no project checks"
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

          it_behaves_like "no project checks"
        end
      end

      context "when project check was never checked before" do
        let!(:project_2_check) do
          create(:project_check,
                 project: project_2,
                 reminder: reminder,
                 last_check_date: nil,
                 created_at: Time.zone.now - 3.days)
        end

        context "when jira issue should be created 7 days before next check" do
          it "returns 1 projeck check" do
            expect(subject.count).to eq(1)
            expect(subject.first).to eq(project_2_check)
          end
        end

        context "when jira issue should be created 6 days before next check" do
          let(:jira_issue_lead) { 6 }

          it_behaves_like "no project checks"
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

          it_behaves_like "no project checks"
        end
      end
    end

    context "when issue has been disabled for some time" do
      context "when jira task should be created" do
        let(:last_check_date) { Time.zone.today - 123.days }

        let!(:project_2_check) do
          create(:project_check,
                 project: project_2,
                 reminder: reminder,
                 last_check_date: last_check_date,
                 last_check_date_without_disabled_period: Time.zone.today - 23.days)
        end

        it "returns 1 project check" do
          expect(subject.count).to eq(1)
          expect(subject.first).to eq(project_2_check)
        end
      end

      context "when jira issue should not be created" do
        let(:last_check_date) { Time.zone.today - 23.days }

        let!(:project_2_check) do
          create(:project_check,
                 project: project_2,
                 reminder: reminder,
                 last_check_date: last_check_date,
                 last_check_date_without_disabled_period: Time.zone.today - 22.days)
        end

        it_behaves_like "no project checks"
      end
    end
  end
end
