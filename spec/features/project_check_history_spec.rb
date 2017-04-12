require "rails_helper"

feature "project checks history", type: :feature do
  let(:project) { create(:project) }
  let(:reminder) { create(:reminder) }
  let!(:project_check) do
    create(:project_check,
           project: project,
           reminder: reminder,
          )
  end

  let(:user) { create(:user, uid: "213312", provider: "google_oauth2") }
  let(:reminders_page) { Reminders::ReminderPage.new }

  before do
    log_in(user)
  end

  scenario "history shows done checks", js: true do
    reminders_page.load reminder_id: reminder.id

    expect(page).not_to have_content user.name
    page.find(".btn", text: "I've done this!").click
    page.find(".btn").click

    expect(page).to have_content user.name

    page.find(".btn", text: "Show").click
    expect(page).to have_content user.name
  end
end
