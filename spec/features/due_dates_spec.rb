require "rails_helper"

feature "Due dates of project checks", type: :feature do
  let(:user) { create(:admin) }
  let(:reminder_page) { Reminders::ReminderPage.new }
  let(:reminder) do
    create :reminder,
           valid_for_n_days: 30,
           init_valid_for_n_days: 30,
           remind_after_days: [],
           init_remind_after_days: [],
           deadline_text: "Days ago: {{days_ago}}",
           init_deadline_text: "Days ago: {{days_ago}}",
           notification_text: "Days ago: {{days_ago}}",
           init_notification_text: "Days ago: {{days_ago}}"
  end
  let(:project) { create :project }
  let!(:project_check) do
    create :project_check, reminder: reminder, project: project
  end

  before do
    log_in(user)
    ActionMailer::Base.deliveries = []
    reminder_page.load reminder_id: reminder.id
  end

  def disable_project_check_until!(new_date)
    reminder_page.project_rows.first.toggle_state!

    Timecop.travel(new_date)
    reminder_page.within(".project-checks-filters") { click_link "Disabled" }
    reminder_page.project_rows.first.toggle_state!
  end

  def reload!
    reminder_page.load reminder_id: reminder.id
  end

  context "A project_check that was never checked" do
    let(:days) { reminder_page.project_rows.first.deadline.input }

    scenario "and isn't overdue" do
      Timecop.travel(10.days.from_now)
      CheckReminderJob.new.perform reminder.id
      reload!

      expect(days.value).to eq "20"
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    scenario "and would be overdue if it wasn't disabled", js: true do
      Timecop.travel(5.days.from_now)
      disable_project_check_until!(20.days.from_now)
      Timecop.travel(3.days.from_now)
      reload!

      expect(days.value).to eq "22"
    end

    scenario "and is overdue despite being disabled for a period of time", js: true do
      Timecop.travel(20.days.from_now)
      disable_project_check_until!(10.days.from_now)
      Timecop.travel(20.days.from_now)
      CheckReminderJob.new.perform reminder.id
      reload!

      expect(days[:placeholder]).to eq "after deadline"
      emails = ActionMailer::Base.deliveries
      expect(emails.count).to eq 1
      expect(emails.first.body.raw_source).to include "Days ago: 40"
    end
  end

  context "A project_check that was checked before" do
    let(:days) { reminder_page.project_rows.first.deadline.text }

    before do
      Timecop.travel(5.days.from_now)
      reminder_page.project_rows.first.mark_as_checked!
    end

    scenario "and isn't overdue" do
      Timecop.travel(20.days.from_now)
      reload!

      expect(days).to eq "10"
    end

    scenario "and would be overdue if it wasn't disabled", js: true do
      disable_project_check_until!(20.days.from_now)
      Timecop.travel(3.days.from_now)
      reload!

      expect(days).to eq "27"
    end

    scenario "and is overdue despite being disabled for a period of time", js: true do
      Timecop.travel(20.days.from_now)
      disable_project_check_until!(10.days.from_now)
      Timecop.travel(20.days.from_now)
      CheckReminderJob.new.perform reminder.id
      reload!

      expect(days).to eq "after deadline"
      emails = ActionMailer::Base.deliveries
      expect(emails.count).to eq 1
      expect(emails.first.body.raw_source).to include "Days ago: 40"
    end
  end
end
