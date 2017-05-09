require "rails_helper"

describe Notifier do
  let(:channels_list) do 
    { 
      "channels" =>
        [
          { "id" => "AA1", "name" => "chan", "previous_names" => [] },
          { "id" => "AA2", "name" => "chan1", "previous_names" => [] },
          { "id" => "AA3", "name" => "chan2", "previous_names" => []  },
          { "id" => "AA4", "name" => "chan3", "previous_names" => []  },
          { "id" => "AA5", "name" => "new_name", "previous_names" => ["old_name"]  },
        ]
    }
  end
  let(:client) { double(send_message: true, channels_list: channels_list) }
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
      context "when channel provided as array with one item" do
        let(:options) { { channels: %w(chan) } }

        it "sends one message to client" do
          expect(client).to receive(:chat_postMessage)
            .with(default_message.merge(channel: "#chan"))
            .and_return(ok: true)
          expect(client).to receive(:channels_list).and_return(channels_list)
          notifier.send_message message, options
        end
      end

      context "when channel provided as string" do
        let(:options) { { channels: "chan" } }

        it "sends one message to client" do
          expect(client).to receive(:chat_postMessage)
            .with(default_message.merge(channel: "#chan"))
            .and_return(ok: true)
          notifier.send_message message, options
        end
      end
    end

    context "when options contain 3 channels" do
      context "when channels provided as array with three items" do
        let(:options) { { channels: %w(chan1 chan2 chan3) } }

        it "sends 3 messages to client" do
          expect(client).to receive(:chat_postMessage)
            .with(default_message.merge(channel: "#chan1"))
            .and_return(ok: true)
          expect(client).to receive(:chat_postMessage)
            .with(default_message.merge(channel: "#chan2"))
            .and_return(ok: true)
          expect(client).to receive(:chat_postMessage)
            .with(default_message.merge(channel: "#chan3"))
            .and_return(ok: true)
          notifier.send_message message, options
        end
      end

      context "when channels provided as string" do
        let(:options) { { channels: "chan1 chan2 chan3" } }

        it "sends 3 messages to client" do
          expect(client).to receive(:chat_postMessage)
            .with(default_message.merge(channel: "#chan1"))
            .and_return(ok: true)
          expect(client).to receive(:chat_postMessage)
            .with(default_message.merge(channel: "#chan2"))
            .and_return(ok: true)
          expect(client).to receive(:chat_postMessage)
            .with(default_message.merge(channel: "#chan3"))
            .and_return(ok: true)
          notifier.send_message message, options
        end
      end
    end

    context "when channel changed name" do
      let(:options) { { channels: %w(old_name) } }

      it "sends one message to client using ID of channel" do
        expect(client).to receive(:chat_postMessage)
          .with(default_message.merge(channel: "AA5"))
          .and_return(ok: true)
        expect(client).to receive(:channels_list).and_return(channels_list)
        notifier.send_message message, options
      end
    end

    context "when channel does not exist" do
      let(:options) { { channels: %w(non_existing_channel) } }

      it "does not send any messages" do
        expect(client).not_to receive(:any)
        expect(client).to receive(:channels_list).and_return(channels_list)
        notifier.send_message message, options
      end
    end
  end
end
