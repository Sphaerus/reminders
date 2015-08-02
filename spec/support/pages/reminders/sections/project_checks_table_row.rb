require_relative "../sections/project_checks_history_table.rb"

module Reminders
  class ProjectChecksTableRow < SitePrism::Section
    element :project, "td:first"
    element :last_check_date, "td[2]"
    element :last_checker, "td[4]"
    element :history_button, "td[5]"
    element :check_button, "td[6] button"
    element :toggle_state_button, ".toggle-state a"
    element :assigned_reviewer, ".assigned-person"
    element :pick_random_button, ".pick-random-button"
    section :history_table, ProjectChecksHistoryTable,
            :xpath, "ancestor::tbody/following-sibling::tbody",
            match: :first

    def id
      root_element[:id]
    end

    def disabled?
      toggle_state_button[:class] == "btn btn-success"
    end

    def toggle_state
      toggle_state_button.click
    end
  end
end
