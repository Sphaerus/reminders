require "rails_helper"

describe CheckAssignments::RemindPendingCheckAssignment do
  include RepositoriesHelpers

  let(:service) do
    described_class
      .new(project_check: project_check, reminder: reminder,
           check_assignments_repository: check_assignments_repository)
  end
  let(:checked) { true }
  let(:init_remind_after_days) { [3, 5] }
  let(:init_valid_for_n_days) { 7 }
  let(:remind_after_days) { [1, 2, 3, 4, 5, 15] }
  let(:valid_for_n_days) { 20 }
  let(:user) { double(:user, id: 1, email: "john@doe.pl") }
  let(:check_assignment) do
    double(:check_assignment,
           id: 1, user_id: 1, project_check_id: 1, completion_date: nil,
           created_at: nil
          )
  end

  let(:project_check) do
    double(:project_check, id: 1, created_at: Time.current, reminder: reminder, checked?: checked)
  end

  let(:reminder) do
    double(:reminder, id: 1,
           valid_for_n_days: valid_for_n_days,
           init_valid_for_n_days: init_valid_for_n_days,
           remind_after_days: remind_after_days,
           init_remind_after_days: init_remind_after_days)
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

    context "when check has assigned user and it's after deadline" do
      before do
        allow(check_assignment).to receive(:created_at) { 21.days.ago }
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

    context "when project has not been checked before" do
      let(:checked) { false }

      context "when it should be reminded because overdue" do
        before do
          allow(check_assignment).to receive(:created_at) { 8.days.ago }
          check_assignments_repository.all = [check_assignment]
          allow(UserReminderMailer)
            .to receive_message_chain(:check_assignment_remind, :deliver_now)
        end

        it "sends reminder" do
          expect(UserReminderMailer).to receive(:check_assignment_remind)
        end
      end

      context "when it should be reminded because reminder day" do
        before do
          allow(check_assignment).to receive(:created_at) { 5.days.ago }
          check_assignments_repository.all = [check_assignment]
          allow(UserReminderMailer)
            .to receive_message_chain(:check_assignment_remind, :deliver_now)
        end

        it "sends reminder" do
          expect(UserReminderMailer).to receive(:check_assignment_remind)
        end
      end

      context "when it should not be reminded because not overdue and not reminder day" do
        before do
          allow(check_assignment).to receive(:created_at) { 6.days.ago }

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
end
