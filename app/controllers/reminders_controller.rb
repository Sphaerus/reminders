class RemindersController < ApplicationController
  before_action :authenticate_admin!,
                only: [:edit, :sync_projects, :create, :update, :destroy]

  expose(:reminders_repository) { RemindersRepository.new }
  expose(:reminders) do
    ReminderDecorator::Base.decorate_collection(
      reminders_repository.all.includes(:project_checks))
  end
  expose(:reminder) { reminders_repository.find(params[:id]) }
  expose(:project_checks_repository) { ProjectChecksRepository.new }
  expose(:project_checks) do
    checks = project_checks_repository.for_reminder(reminder)
    ProjectCheckDecorator.decorate_collection checks
  end
  expose(:projects_repository) { ProjectsRepository.new }
  expose(:users) { UsersWithSkillRepository.new(reminder).all }

  def index; end

  def show
    self.reminder = ReminderDecorator::Base.decorate(reminder)
  end

  def new
    self.reminder = ReminderDecorator::Form.new Reminder.new
  end

  def edit
    self.reminder = ReminderDecorator::Form.new reminder
  end

  def sync_projects
    reminder = reminders_repository.find params[:reminder_id]
    Reminders::SyncProjects.new(reminder).call
    redirect_to reminder, notice: "Projects have been synchronized."
  end

  def create
    create_reminder = Reminders::Create.new(reminder_attrs).call
    if create_reminder.success?
      redirect_to create_reminder.data,
                  notice: "Reminder was successfully created."
    else
      self.reminder = ReminderDecorator::Form.decorate create_reminder.data
      render :new
    end
  end

  def update
    update_reminder = Reminders::Update.new(reminder, reminder_attrs).call
    if update_reminder.success?
      redirect_to update_reminder.data,
                  notice: "Reminder was successfully updated."
    else
      self.reminder = ReminderDecorator::Form.decorate update_reminder.data
      render :edit
    end
  end

  def destroy
    Reminders::Delete.new(reminder).call
    redirect_to reminders_url, notice: "Reminder was successfully destroyed."
  end

  def move_up
    Reminders::Reorder.new(reminder, :up).call
    redirect_to reminders_url
  end

  def move_down
    Reminders::Reorder.new(reminder, :down).call
    redirect_to reminders_url
  end

  private

  def reminder_attrs
    params.require(:reminder)
          .permit(:name, :valid_for_n_days, :remind_after_days,
                  :notification_text, :deadline_text, :slack_channel,
                  :supervisor_slack_channel, :notify_projects_channels,
                  :jira_issue_lead)
  end
end
