require "rails_helper"

describe Reminder do
  let!(:reminder) { create(:reminder) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_least(3) }
  it { is_expected.to validate_presence_of(:deadline_text) }
  it { is_expected.to validate_length_of(:deadline_text).is_at_least(10) }
  it { is_expected.to validate_presence_of(:notification_text) }
  it { is_expected.to validate_length_of(:notification_text).is_at_least(10) }
  it { is_expected.to validate_numericality_of(:valid_for_n_days) }
  it do
    is_expected.to validate_numericality_of(:jira_issue_lead)
      .is_greater_than_or_equal_to(0)
      .only_integer
  end
  it { is_expected.to allow_value("").for(:jira_issue_lead) }
  it do
    is_expected.to validate_numericality_of(:order)
      .is_greater_than_or_equal_to(0)
      .only_integer
  end

  it { is_expected.to have_many(:project_checks).dependent(:destroy) }
  it { is_expected.to have_many(:projects).through(:project_checks) }
  it { is_expected.to have_many(:check_assignments).through(:project_checks).dependent(:destroy) }
  it { is_expected.to have_many(:skills).dependent(:destroy) }

  context "Destroing" do
    let!(:project_check) { create(:project_check, reminder: reminder) }
    let(:user) { create(:user) }
    let!(:check_assignment) do
      create(:check_assignment, project_check: project_check, user: user)
    end
    let!(:skill) { create(:skill, user: user, reminder: reminder) }

    it "deletes reminder" do
      expect { reminder.destroy }.to change { Reminder.count }.by(-1)
    end

    it "deletes dependent project_checks" do
      expect { reminder.destroy }.to change { ProjectCheck.count }.by(-1)
    end

    it "deletes dependent check_assignments" do
      expect { reminder.destroy }.to change { CheckAssignment.count }.by(-1)
    end

    it "deletes dependent skills" do
      expect { reminder.destroy }.to change { Skill.count }.by(-1)
    end
  end
end
