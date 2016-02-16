require "rails_helper"

feature "filtering projects", js: true do
  let(:user) { create(:admin) }
  let(:projects_page) { Projects::ProjectsPage.new }
  let!(:project_active) { create(:project) }
  let!(:project_archived) { create(:project, archived_at: '2000-01-01') }

  before do
    log_in(user)
    visit projects_path
  end

  context "user is filtering projects" do
    scenario "user visits page with default filtering" do
      expect(page).to have_content project_active.name
      expect(page).not_to have_content project_archived.name
    end
    scenario "user uses filter 'All'" do
      click_link('All')
      expect(page).to have_content project_active.name
      expect(page).to have_content project_archived.name
    end
    scenario "user uses filter 'Archived'" do
      click_link('Archived')
      expect(page).not_to have_content project_active.name
      expect(page).to have_content project_archived.name
    end
    scenario "user uses filter 'Active'" do
      click_link('Active')
      expect(page).to have_content project_active.name
      expect(page).not_to have_content project_archived.name
    end
  end
end
