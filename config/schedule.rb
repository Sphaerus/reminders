# Learn more: http://github.com/javan/whenever

# Monday-Friday at 9:30AM
every "30 9 * * 1-5" do
  rake "reminders:check_all"
end
