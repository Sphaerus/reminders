require "rails_helper"

feature "reassign user to perform check", type: :feature do
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
    Skill.create!(user_id: user.id, reminder_id: reminder.id)
    Skill.create!(user_id: second_user.id, reminder_id: reminder.id)
    create(:check_assignment, user: user, project_check: project_check,
                              completion_date: nil)
  end

  scenario "there is user assigned already", focus: true do
    reminder_page.load reminder_id: reminder.id

    expect(reminder_page.first_project)
      .to have_text user.name
    expect(reminder_page.first_project)
      .to_not have_link("Pick person")
    expect(reminder_page.first_project)
      .to have_link("Reassign")

    reminder_page.first_project.reassign_random_button.click
    pick_person_page = Reminders::PickPersonPage.new
    expect(pick_person_page).to be_displayed
    expect(pick_person_page.flash_notice).to be_present
    expect(pick_person_page.flash_notice.text)
      .to include("The previous assignment has been canceled.")
    preffered_user = pick_person_page.users.second
    expect(preffered_user.root_element).to have_text(second_user.name)

    preffered_user.pick_button.click
    expect(reminder_page.first_project.assigned_reviewer)
      .to have_text second_user.name
    expect(reminder_page.first_project)
      .not_to have_link("Pick person")
  end
end
