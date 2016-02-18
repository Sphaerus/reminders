class UserNotificationMailer < ApplicationMailer
  def check_assignment(user, project_check, contact_person)
    @project_check = project_check
    @user = user
    @contact_person = contact_person
    mail(to: user.email,
         subject: compose_subject, &:html)
  end

  private

  def compose_subject
    "You have been assigned to do next #{@project_check.reminder.name}
    in #{@project_check.project.name}"
  end
end
