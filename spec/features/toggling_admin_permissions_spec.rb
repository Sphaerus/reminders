require "rails_helper"

feature "toggling admin permissions", type: :feature do
  let(:user) do
    create(:user,
           uid: "12331", provider: "google_oauth2",
           email: "john@doe.pl", admin: true)
  end
  let(:second_user) do
    create(:user, name: "John Smith", email: "john@smith@foo.pl")
  end
  let(:page) { Users::UsersPage.new }

  before do
    log_in(user)
    second_user.touch
  end

  scenario "toggling admin permissions", focus: true do
    page.load

    expect(page.user_rows.first).to have_admin_label
    expect(page.user_rows.second).to_not have_admin_label

    page.user_rows.second.toggle_admin_permissions!

    expect(page).to have_flash_notice
    expect(page.flash_notice.text)
      .to include("User's permissions has been changed.")
    expect(page.user_rows.second).to have_admin_label

    page.user_rows.second.toggle_admin_permissions!

    expect(page.user_rows.second).to_not have_admin_label
  end
end
