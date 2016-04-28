require "rails_helper"

describe ReminderDecorator::Base do
  let(:reminder) { OpenStruct.new }
  let(:decorator) { described_class.new(reminder) }

  describe "#slack_channel_display" do
    context "slack_channel present" do
      it "return slack_channel" do
        reminder.slack_channel = "channel"
        expect(decorator.slack_channel_display).to eq("channel")
      end
    end

    context "slack_channel not present" do
      it "return placeholder string" do
        reminder.slack_channel = ""
        expect(decorator.slack_channel_display).to eq("Not specified.")
      end
    end
  end

  describe "#supervisor_slack_channel_display" do
    context "supervisor_slack_channel present" do
      it "return supervisor_slack_channel" do
        reminder.supervisor_slack_channel = "channel"
        expect(decorator.supervisor_slack_channel_display).to eq("channel")
      end
    end

    context "supervisor_slack_channel not present" do
      it "return placeholder string" do
        reminder.supervisor_slack_channel = ""
        expect(decorator.supervisor_slack_channel_display).to eq("Not specified.")
      end
    end
  end
end
