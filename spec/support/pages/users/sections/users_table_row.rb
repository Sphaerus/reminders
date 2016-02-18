module Users
  class UsersTableRow < SitePrism::Section
    element :admin, ".pick-random-button"
    element :toggle_admin_button, "#toggle-admin-button"
    element :admin_label, ".label.label-primary"
    element :toggle_paused_button, ".toggle-switch"

    def toggle_admin_permissions!
      toggle_admin_button.click
    end

    def paused?
      evaluate_script("$('.toggle-switch').attr('checked')").nil?
    end

    def pause!
      return if evaluate_script("$('.toggle-switch').attr('checked')").nil?
      toggle_user_availability
    end

    def unpause!
      return unless evaluate_script("$('.toggle-switch').attr('checked')").nil?
      toggle_user_availability
    end

    def toggle_user_availability
      execute_script("$('.toggle-switch').click()")
    end
  end
end
