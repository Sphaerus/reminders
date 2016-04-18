class ProjectChecksHistoryTable < SitePrism::Section
  elements :checks, "tr.single_check"

  def checks_number
    checks.count
  end

  def content
    root_element.text
  end
end
