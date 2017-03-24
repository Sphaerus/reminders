require "rails_helper"

describe Reminders::Reorder do
  let(:reminder) { create(:reminder) }

  describe ".new" do
    it "raises an error if second argument isn't :up or :down" do
      expect { described_class.new(reminder, :a) }.to raise_error ArgumentError
    end
  end

  describe "#call" do
    let!(:first_reminder)  { create(:reminder, order: 0) }
    let!(:second_reminder) { create(:reminder, order: 1) }
    let!(:third_reminder)  { create(:reminder, order: 2) }

    context "given :up direction" do
      it "reorders all reminders to move the given one up" do
        described_class.new(second_reminder, :up).call

        expect(second_reminder.reload.order).to eq 0
      end

      context "when out of range" do
        it "doesn't change the order" do
          described_class.new(first_reminder, :up).call

          expect(first_reminder.reload.order).to eq 0
        end
      end
    end

    context "given :down direction" do
      it "reorders all reminders to move the given one down" do
        described_class.new(second_reminder, :down).call

        expect(second_reminder.reload.order).to eq 2
      end

      context "when out of range" do
        it "doesn't change the order" do
          described_class.new(third_reminder, :down).call

          expect(third_reminder.reload.order).to eq 2
        end
      end
    end
  end
end
