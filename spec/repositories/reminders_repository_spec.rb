require "rails_helper"

describe RemindersRepository do
  let(:repo) { described_class.new }

  describe "#all" do
    it "returns all the reminders" do
      2.times { create(:reminder) }
      expect(repo.all.count).to eq 2
    end

    it "orders reminders by order column" do
      create(:reminder, order: 1, name: "second")
      create(:reminder, order: 0, name: "first")
      create(:reminder, order: 2, name: "third")

      expect(repo.all.pluck(:name)).to eq %w{first second third}
    end
  end

  describe "#create" do
    let(:reminder) { build(:reminder) }

    it "saves object" do
      repo.create reminder
      expect(reminder.persisted?).to eq true
    end

    it "sets default order for the created object" do
      create(:reminder, order: 5)

      repo.create reminder

      expect(reminder.order).to eq 6
    end
  end

  describe "#update" do
    let!(:reminder) { create(:reminder) }

    it "updates object" do
      reminder.name = "bar"
      repo.update reminder
      expect(repo.find(reminder.id).name).to eq "bar"
    end
  end

  describe "#delete" do
    let!(:reminder) { create(:reminder) }

    it "removes object from db" do
      repo.delete reminder
      expect(repo.find(reminder.id)).to eq nil
    end
  end
end
