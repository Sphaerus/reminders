require_relative "../sections/project_checks_history_table.rb"

module Reminders
  class ProjectChecksTableRow < SitePrism::Section
    element :project, "td:first"
    element :last_check_date, "td:nth-child(2)"
    section :deadline, "td:nth-child(3)" do
      element :input, "input#project_check_days_left"
      delegate :text, to: :root_element
    end
    element :last_checker, "td:nth-child(5)"
    element :history_button, "td:nth-child(6)"
    element :complete_check_link, "td:nth-child(7) a"
    element :toggle_state_button, ".toggle-state form"
    element :assigned_reviewer, ".assigned-person"
    element :pick_random_button, ".pick-random-button"
    element :reassign_random_button, ".reassign-random-button"
    section :history_table, ProjectChecksHistoryTable,
            :xpath, "ancestor::tbody/following-sibling::tbody",
            match: :first

    def id
      root_element[:id]
    end

    def disabled?
      evaluate_script("$('.toggle-switch').attr('checked')").nil?
    end

    def mark_as_checked!
      complete_check_link.click
      fill_in("Note url", with: "http://example.com")
      click_button("Add a note URL and mark as done")
    end

    def toggle_state!
      toggle_state_button.click
    end
  end
end
