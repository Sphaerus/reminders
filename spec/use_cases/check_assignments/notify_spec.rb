require "rails_helper"

describe CheckAssignments::Notify do
  let(:service) { described_class.new }
  let(:message) { "Message." }
  let(:channel) { "test" }

  describe "#notify" do
    context "with disabled Slack" do
      before do
        AppConfig["slack_enabled"] = "false"
      end

      it "returns message of unsuccessful notification" do
        expect(service.call(channel, message))
          .to eq(
            "Message. Something went wrong and we couldn't notify channel.",
          )
      end
    end

    context "with enabled Slack" do
      let(:full_message) { "Just letting you know that #{message}" }
      before do
        AppConfig["slack_enabled"] = "true"
        allow_any_instance_of(Notifier).to receive(:notify_slack)
          .and_return(true)
      end

      it "makes call to Notifier" do
        expect_any_instance_of(Notifier)
          .to receive(:notify_slack).with(full_message, channels: channel)
        service.call(channel, message)
      end

      context "after successful notification" do
        before do
          allow_any_instance_of(Notifier).to receive(:notify_slack).and_return(true)
          allow_any_instance_of(Notifier).to receive(:result).and_return(true)
        end

        it "returns ok message" do
          expect(service.call(channel, message))
            .to eq(
              "Message. We have notified project's channel.",
            )
        end
      end

      context "after unsuccessful notification" do
        before do
          allow_any_instance_of(Notifier).to receive(:notify_slack)
            .and_return(false)
          allow_any_instance_of(Notifier).to receive(:result).and_return(false)
        end

        it "returns fail message" do
          expect(service.call(channel, message))
            .to eq(
              "Message. Something went wrong and we couldn't notify channel.",
            )
        end
      end
    end
  end
end
