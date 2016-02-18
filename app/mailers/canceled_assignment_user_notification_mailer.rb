class CanceledAssignmentUserNotificationMailer < ApplicationMailer
  def canceled_assignment(user, project_check)
    @project_check = project_check
    @user = user
    mail(to: user.email,
         subject: compose_subject, &:html)
  end

  private

  def compose_subject
    "Your assignment to do next #{@project_check.reminder.name}
    in #{@project_check.project.name} has been canceled"
  end
end
