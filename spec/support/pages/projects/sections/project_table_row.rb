module Projects
  class ProjectTableRow < SitePrism::Section
    def disabled?
      evaluate_script("$('.js-toggle-switch').attr('checked')").nil?
    end

    def disable
      return if evaluate_script("$('.toggle-switch').attr('checked')").nil?
      execute_script("$('.toggle-switch').click()")
    end
  end
end
