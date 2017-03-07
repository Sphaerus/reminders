require "rails_helper"

describe Notifier do
  let(:client) { double(send_message: true) }
  let(:notifier) { described_class.new(client) }

  before do
    notifier.slack_enabled = true
  end

  describe "#send_message" do
    let(:message) { "hello world" }
    let(:default_message) do
      { text: message, username: "Reminders App", icon_emoji: ":loudspeaker:" }
    end

    context "when options contain no channel" do
      let(:options) { {} }

      it "doesn't send any messages to client" do
        expect(client).not_to receive(:any)
        notifier.send_message message, options
      end
    end

    context "when options contain one channel" do
      let(:options) { { channel: "chan" } }

      it "sends one message to client" do
        expect(client).to receive(:chat_postMessage).with(default_message.merge(channel: "#chan"))
        notifier.send_message message, options
      end
    end

    context "when options contain 3 channels" do
      let(:options) { { channel: "chan1 chan2 chan3" } }

      it "sends 3 messages to client" do
        expect(client).to receive(:chat_postMessage).with(default_message.merge(channel: "#chan1"))
        expect(client).to receive(:chat_postMessage).with(default_message.merge(channel: "#chan2"))
        expect(client).to receive(:chat_postMessage).with(default_message.merge(channel: "#chan3"))
        notifier.send_message message, options
      end
    end
  end
end
