require "rails_helper"

feature "marking project as checked" do
  let(:project) { create(:project) }
  let(:reminder) { create(:reminder) }
  let!(:project_check) do
    create(:project_check,
           project: project,
           reminder: reminder,
          )
  end
  let(:user) { User.first }

  before do
    log_in(user)
  end

  context "when project hasn't been checked yet" do
    scenario "user marks project as checked" do
      visit reminder_path(reminder)
      expect(page).not_to have_text user.name
      expect(page).to have_text "not checked yet"

      click_button("Check!")

      expect(page).not_to have_text "not checked yet"
      expect(page).to have_text user.name
      expect(page).to have_text project_check.last_check_date
    end
  end
end
