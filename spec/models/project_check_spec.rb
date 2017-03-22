require "rails_helper"

describe ProjectCheck do
  it { is_expected.to belong_to :project }
  it { is_expected.to belong_to :reminder }
  it { is_expected.to belong_to(:last_check_user).class_name("User") }
  it do
    is_expected.to have_many(:check_assignments)
      .order(created_at: :desc)
      .dependent(:destroy)
  end

  it "validates that project is enabled before enabling self" do
    project_check = create(:project_check,
                           enabled: false,
                           project: create(:project, enabled: false))
    project_check.update(enabled: true)
    expect(project_check).not_to be_valid
  end
end
