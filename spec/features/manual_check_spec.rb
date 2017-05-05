require "rails_helper"

feature "manual check", type: :feature do
  let(:project) { create(:project) }
  let(:reminder) { create(:reminder) }
  let!(:project_check) do
    create(:project_check,
           project: project,
           reminder: reminder)
  end

  let(:user) { create(:admin, uid: "213312", provider: "google_oauth2", admin: true) }
  let(:reminders_page) { Reminders::ReminderPage.new }

  before do
    log_in(user)
  end

  background do
    reminders_page.load reminder_id: reminder.id
    page.find(".btn", text: "Show").click
  end

  scenario "admin adds manual check with note url", js: true do
    page.fill_in("Note url", with: "some url")
    page.find("#manual_check_user_id > option:nth-child(2)").click
    page.find("#add-manual-check").click
    expect(page).to have_content "Manual entry added"
  end

  scenario "admin adds manual check without note url", js: true do
    page.find("#manual_check_user_id > option:nth-child(2)").click
    page.find("#add-manual-check").click
    expect(page).not_to have_content "Manual entry added"
  end
end
