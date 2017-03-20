# Learn more: http://github.com/javan/whenever

# Monday-Friday at 9:30AM
every "30 9 * * 1-5" do
  rake "reminders:check_all"
end

# Monday-Friday at 9:45AM
every "45 9 * * 1-5" do
  rake "reminders:create_jira_issues"
end
