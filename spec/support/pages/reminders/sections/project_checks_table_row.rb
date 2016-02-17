require_relative "../sections/project_checks_history_table.rb"

module Reminders
  class ProjectChecksTableRow < SitePrism::Section
    def id
      root_element[:id]
    end

    def disabled?
      evaluate_script("$('.toggle-switch').attr('checked')").nil?
    end
  end
end
