class ProjectNotificationMailer < ApplicationMailer
  attr_reader :project_check

  def check_reminder(notification, project_check)
    @project_check = project_check
    @team_name = team_name
    @notification = notification
    mail(to: project_email,
         subject: compose_subject, &:html)
  end

  private

  def compose_subject
    "Reminders: next #{project_check.reminder.name}
    in #{project_check.project.name}"
  end

  def project_email
    project_check.project.email
  end

  def team_name
    @project_check.project.name
  end
end
