module Reminders
  class ReminderTableRow < SitePrism::Section
    element :name, "td:first"
    element :move_up_button, ".move-up"
    element :move_down_button, ".move-down"

    def id
      root_element[:id]
    end
  end
end
