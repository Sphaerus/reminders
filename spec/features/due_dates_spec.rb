require "rails_helper"

feature "Due dates of project checks" do
  let(:user) { create(:admin) }
  let(:reminder_page) { Reminders::ReminderPage.new }
  let(:reminder) do
    create :reminder,
           valid_for_n_days: 30,
           remind_after_days: [],
           deadline_text: "Days ago: {{days_ago}}",
           notification_text: "Days ago: {{days_ago}}"
  end
  let(:project)  { create :project }
  let!(:project_check) do
    create :project_check, reminder: reminder, project: project
  end
  let(:days_to_deadline) do
    reminder_page.project_rows.first.days_to_deadline
  end

  before do
    log_in(user)
  end

  scenario "A project/reminder combo that was never checked" do
    Timecop.travel(10.days.from_now)
    reminder_page.load reminder_id: reminder.id
    CheckReminderJob.new.perform reminder.id

    days = days_to_deadline.find('input#project_check_days_left').value
    expect(days).to eq "20"
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  scenario "A project/reminder combo that was checked before" do
    Timecop.travel(5.days.from_now)
    reminder_page.load reminder_id: reminder.id
    reminder_page.project_rows.first.mark_as_checked!

    Timecop.travel(20.days.from_now)
    reminder_page.load reminder_id: reminder.id
    deadline = reminder_page.project_rows.first.days_to_deadline.text

    expect(deadline).to eq "10"
  end

  scenario "An unchecked project/reminder combo that would be overdue if it wasn't disabled", js: true do
    Timecop.travel(5.days.from_now)
    reminder_page.load reminder_id: reminder.id
    wait_for_jquery
    reminder_page.project_rows.first.toggle_state!

    Timecop.travel(20.days.from_now)
    reminder_page.within('.project-checks-filters') { click_link "Disabled" }
    reminder_page.project_rows.first.toggle_state!

    Timecop.travel(3.days.from_now)
    reminder_page.load reminder_id: reminder.id

    days = reminder_page.project_rows.first.deadline_input.value
    expect(days).to eq "22"
  end

  scenario "A project/reminder combo that would be overdue if it wasn't disabled", js: true do
    Timecop.travel(5.days.from_now)
    reminder_page.load reminder_id: reminder.id
    wait_for_jquery
    reminder_page.project_rows.first.mark_as_checked!
    reminder_page.project_rows.first.toggle_state!

    Timecop.travel(20.days.from_now)
    reminder_page.within('.project-checks-filters') { click_link "Disabled" }
    reminder_page.project_rows.first.toggle_state!

    Timecop.travel(3.days.from_now)
    reminder_page.load reminder_id: reminder.id

    days = reminder_page.project_rows.first.days_to_deadline.text
    expect(days).to eq "27"
  end

  scenario "An overdue check including a disabled period", js: true do
    Timecop.travel(20.days.from_now)
    reminder_page.load reminder_id: reminder.id
    wait_for_jquery
    #reminder_page.project_rows.first.mark_as_checked!
    reminder_page.project_rows.first.toggle_state!

    Timecop.travel(10.days.from_now)
    reminder_page.within('.project-checks-filters') { click_link "Disabled" }
    reminder_page.project_rows.first.toggle_state!

    Timecop.travel(20.days.from_now)
    reminder_page.load reminder_id: reminder.id
    CheckReminderJob.new.perform reminder.id
    emails = ActionMailer::Base.deliveries

    #days = reminder_page.project_rows.first.days_to_deadline.text
    days = reminder_page.project_rows.first.deadline_input[:placeholder]
    expect(days).to eq "after deadline"
    expect(emails.count).to eq 1
    expect(emails.first.body.raw_source).to include "Days ago: 40"
  end
end
