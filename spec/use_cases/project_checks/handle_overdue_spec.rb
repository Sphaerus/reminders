require "rails_helper"

describe ProjectChecks::HandleOverdue do
  let(:service) { described_class.new(check, days_diff, notifier) }
  let(:days_diff) { 10 }
  let(:project) do
    double(:project, name: "foo project", channel_name: "foo-project")
  end
  let(:deadline_text) { "foo bar baz" }
  let(:reminder) do
    double(:reminder, name: "bar baz", valid_for_n_days: 5,
                      deadline_text: deadline_text,
                      slack_channel: nil)
  end
  let(:check) { double(:project_check, reminder: reminder, project: project) }
  let(:notifier) { double(:notifier, send_message: true) }

  before do
    allow(project).to receive(:decorate) { project }

    allow(project)
      .to receive(:email) { "foo-project@foo.com" }
    allow(check).to receive(:decorate) { check }
    allow(check).to receive(:slack_channel) { "foo-project" }
  end

  describe "#call" do
    it "passes message to notifier" do
      expect(notifier).to receive(:send_message)
        .with(deadline_text, channel: "#foo-project")
      service.call
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

      it "sends email to project's email" do
        service.call
        expect(ActionMailer::Base.deliveries.last.to)
          .to include "foo-project@foo.com"
      end
    end

    context "passing variables works correctly for" do
      after do
        service.call
      end

      it "days_ago" do
        expect(reminder).to receive(:deadline_text)
          .and_return("{{ days_ago }} days ago")

        expect(notifier).to receive(:send_message)
          .with("10 days ago", anything)
      end

      it "project_name" do
        expect(reminder).to receive(:deadline_text)
          .and_return("project {{ project_name }}")

        expect(notifier).to receive(:send_message)
          .with("project foo project", anything)
      end

      it "reminder_name" do
        expect(reminder).to receive(:deadline_text)
          .and_return("{{ reminder_name }} reminder")

        expect(notifier).to receive(:send_message)
          .with("bar baz reminder", anything)
      end

      it "valid_for" do
        expect(reminder).to receive(:deadline_text)
          .and_return("is valid for {{ valid_for }} days")

        expect(notifier).to receive(:send_message)
          .with("is valid for 5 days", anything)
      end
    end
  end
end
