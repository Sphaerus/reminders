require "rails_helper"

feature "pausing users", type: :feature do
  let(:user) do
    create(:user,
           uid: "12331", provider: "google_oauth2",
           email: "john@doe.pl", admin: true, paused: false)
  end
  let(:users_page) { Users::UsersPage.new }

  before do
    log_in(user)
  end

  scenario "toggling state of paused in '/users' page", js: true do
    users_page.load
    expect(users_page.user_rows.first.paused?).to be false
    users_page.user_rows.first.pause!
    wait_for_jquery
    expect(users_page.user_rows.first.paused?).to be true
    expect(user.reload.paused).to be true
    users_page.user_rows.first.unpause!
    wait_for_jquery
    expect(users_page.user_rows.first.paused?).to be false
  end
end
