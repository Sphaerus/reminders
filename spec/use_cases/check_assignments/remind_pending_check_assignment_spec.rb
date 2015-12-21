require "rails_helper"

describe CheckAssignments::RemindPendingCheckAssignment do
  include RepositoriesHelpers

  let(:service) do
    described_class
      .new(project_check: project_check, remind_after_days: remind_after_days,
           check_assignments_repository: check_assignments_repository)
  end
  let(:remind_after_days) { [1, 2, 3, 4, 5, 15] }
  let(:user) { double(:user, id: 1, email: "john@doe.pl") }
  let(:check_assignment) do
    double(:check_assignment,
           id: 1, user_id: 1, project_check_id: 1, completion_date: nil,
           created_at: nil
          )
  end

  let(:project_check) do
    double(:project_check, id: 1, created_at: Time.current, reminder_id: 1)
  end

  let(:check_assignments_repository) do
    class CheckAssignmentsInMemoryRepository < InMemoryRepository
      def latest_assignment(_project_check, _completed: false)
        all.last
      end
    end
    CheckAssignmentsInMemoryRepository.new
  end

  describe "#perform" do
    after do
      service.call
    end

    context "when check has no one assigned" do
      it "doesn't send any reminder" do
        expect(UserReminderMailer).to_not receive(:check_assignment_remind)
      end
    end

    context "when check has assigned user today" do
      before do
        allow(check_assignment).to receive(:created_at) { Time.current }
        check_assignments_repository.all = [check_assignment]
      end

      it "doesn't send any reminder" do
        expect(UserReminderMailer).to_not receive(:check_assignment_remind)
      end
    end

    context "when check has assigned user but remind_after_days doesn't tell" \
      "anything about reminding today" do
      before do
        allow(check_assignment).to receive(:created_at) { 6.days.ago }
        check_assignments_repository.all = [check_assignment]
      end

      it "doesn't send any reminder" do
        expect(UserReminderMailer).to_not receive(:check_assignment_remind)
      end
    end

    context "when check has assigned user within remind_after_days range" do
      before do
        date = remind_after_days.sample.days.ago
        allow(check_assignment).to receive(:created_at) { date }
        allow(UserReminderMailer)
          .to receive_message_chain(:check_assignment_remind, :deliver_now)
        check_assignments_repository.all = [check_assignment]
      end

      it "sends reminder" do
        expect(UserReminderMailer).to receive(:check_assignment_remind)
      end
    end

    context "when check has completion_date" do
      before do
        allow(check_assignment).to receive(:created_at) { 15.days.ago }
        allow(check_assignment).to receive(:completion_date) { Time.current }

        allow(UserReminderMailer)
          .to receive_message_chain(:check_assignment_remind, :deliver)
        check_assignments_repository.all = [check_assignment]
      end

      it "doesn't send any reminder" do
        expect(UserReminderMailer).to_not receive(:check_assignment_remind)
      end
    end
  end
end
