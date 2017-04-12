require "rails_helper"

feature "assign user to perform check", type: :feature do
  let(:project) { create(:project) }
  let(:reminder) { create(:reminder) }
  let!(:project_check) do
    create(:project_check,
           project_id: project.id,
           reminder_id: reminder.id,
          )
  end
  let(:user) do
    create(:user, uid: "12331", provider: "google_oauth2", email: "john@doe.pl")
  end
  let(:second_user) do
    create(:user, name: "John Smith", email: "john@smith@foo.pl")
  end
  let(:reminder_page) { Reminders::ReminderPage.new }

  before do
    log_in(user)
  end

  scenario "there is no user assigned yet", focus: true do
    Skill.create!(user_id: user.id, reminder_id: reminder.id)
    Skill.create!(user_id: second_user.id, reminder_id: reminder.id)
    create(:check_assignment, user: second_user, project_check: project_check,
                              completion_date: 100.days.ago)
    reminder_page.load reminder_id: reminder.id

    expect(reminder_page.first_project)
      .not_to have_text user.name
    expect(reminder_page.first_project)
      .to have_link("Pick person")

    reminder_page.first_project.pick_random_button.click
    pick_person_page = Reminders::PickPersonPage.new
    expect(pick_person_page).to be_displayed
    preffered_user = pick_person_page.users.first
    expect(preffered_user).to have_text(user.name)
    expect(pick_person_page.users.last).to have_text(second_user.name)

    preffered_user.pick_button.click
    expect(reminder_page.first_project.assigned_reviewer)
      .to have_text user.name
    expect(reminder_page.first_project)
      .not_to have_link("Pick person")
  end
end
