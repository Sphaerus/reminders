require "rails_helper"

describe Reminders::Create do
  let(:reminders_repo) { InMemoryRepository.new }
  let(:attrs) { attributes_for(:reminder) }
  let(:service) { described_class.new(attrs, reminders_repo) }

  describe "#call" do
    context "when reminder is valid" do
      it "returns success response" do
        expect(service.call.success?).to be true
      end

      it "creates the object" do
        expect { service.call }.to change { reminders_repo.all.count }.by(1)
      end
    end

    context "when reminder is invalid" do
      let(:attrs) { { name: "" } }
      it "doesn't return success response" do
        expect(service.call.success?).to be false
      end

      it "doesn't create object" do
        expect { service.call }.to_not change { reminders_repo.all.count }
      end
    end

    context "formatting of 'remind_after_days' attribute" do
      it "doesn't save strings" do
        attrs[:remind_after_days] = "foo,bar"
        expect(service.call.data.remind_after_days).to eq []
      end

      it "saves integers separated by comma" do
        attrs[:remind_after_days] = "1,2"
        expect(service.call.data.remind_after_days).to eq %w(1 2)
      end

      it "saves integers separated by comma and with some strange spacing" do
        attrs[:remind_after_days] = "      1,              2"
        expect(service.call.data.remind_after_days).to eq %w(1 2)
      end

      it "save integers only, removing all the string along the way" do
        attrs[:remind_after_days] = "foo, one, 2"
        expect(service.call.data.remind_after_days).to eq %w(2)
      end

      it "saves only unique values" do
        attrs[:remind_after_days] = "1,1,1,1,2, 2 2"
        expect(service.call.data.remind_after_days).to eq %w(1 2)
      end

      it "sorts values from smallest to the biggest one" do
        attrs[:remind_after_days] = "3,1,2"
        expect(service.call.data.remind_after_days).to eq %w(1 2 3)
      end
    end
  end
end
