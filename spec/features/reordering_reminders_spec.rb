require "rails_helper"

feature "Reordering reminders" do
  let(:user) { create(:admin) }
  let(:page) { Reminders::RemindersPage.new }

  before do
    log_in(user)
    create(:reminder, name: "Reminder1")
    create(:reminder, name: "Reminder2")
    create(:reminder, name: "Reminder3")
  end

  scenario "Admin clicks a button with arrow pointing up" do
    page.load
    order_before = %w{Reminder1 Reminder2 Reminder3}
    order_after = %w{Reminder2 Reminder1 Reminder3}

    expect(page.names).to eq(order_before)
    page.reminder_rows.second.move_up_button.click
    expect(page.names).to eq(order_after)
  end

  scenario "Admin clicks a button with arrow pointing down" do
    page.load
    order_before = %w{Reminder1 Reminder2 Reminder3}
    order_after = %w{Reminder1 Reminder3 Reminder2}

    expect(page.names).to eq(order_before)
    page.reminder_rows.second.move_down_button.click
    expect(page.names).to eq(order_after)
  end

  scenario "User opens reminders list" do
    log_in(create(:user))
    page.load
    expect(page).not_to have_css(".move-up")
    expect(page).not_to have_css(".move-down")
  end
end
