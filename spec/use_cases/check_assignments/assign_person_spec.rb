require "rails_helper"

describe CheckAssignments::AssignPerson do
  let(:service) do
    described_class.new(
      project_check: project_check,
      assignments_repo: assignments_repo,
      person: user,
    )
  end
  let(:project_check) do
    double(:project_check,
           id: 2,
           reminder: reminder,
           project: project,
           info: Faker::Lorem.sentence,
          )
  end
  let(:assignments_repo) do
    class InMemoryAssignmentsRepository < InMemoryRepository
      def add(parameters)
        create(CheckAssignment.new(parameters))
      end
    end
    InMemoryAssignmentsRepository.new
  end
  let(:reminder) { double(:reminder, id: 1, name: "sample review") }
  let(:project) { double(:project, name: "test", channel_name: "test") }
  let(:user) { double(:user, name: "John Doe", id: 4, email: "john@doe.pl") }
  let(:message) do
    u = user.name
    r = reminder.name
    p = project.name
    "#{u} got assigned to do next #{r} in #{p}. "
  end

  before do
    allow(project_check).to receive(:decorate) { project_check }
    allow(project_check).to receive(:slack_channel) { "test" }
  end

  describe "#call" do
    it "creates new uncompleted check assignment" do
      expect { service.call }
        .to change { assignments_repo.all.count }
        .by(1)
      expect(assignments_repo.all.first.completion_date).to eq nil
    end

    it "attempts to send Slack notification" do
      expect_any_instance_of(CheckAssignments::Notify)
        .to receive(:call)
        .with(project.channel_name, message)
      service.call
    end

    it "returns notice text" do
      expect(service.call).to be_an_instance_of String
    end

    context "sending email" do
      before do
        ActionMailer::Base.deliveries = []
      end

      it "sends one email" do
        expect { service.call }
          .to change { ActionMailer::Base.deliveries.count }
          .by(1)
      end

      it "sends email to assigned user" do
        service.call
        expect(ActionMailer::Base.deliveries.last.to)
          .to include "john@doe.pl"
      end
    end
  end
end
