require "rails_helper"

describe ProjectDecorator do
  let(:project) { OpenStruct.new(name: "abc", enabled?: true) }
  let(:decorator) { described_class.new(project) }

  describe "#archive_button_class" do
    context "project is archived" do
      before { project.archived_at = Time.current }
      it { expect(decorator.archive_button_class).to eq("disabled") }
      it { expect(decorator.status_text).to eq("archived") }
    end

    context "project is not archived" do
      before { project.archived_at = nil }
      it { expect(decorator.archive_button_class).to be_nil }
      it { expect(decorator.status_text).to eq("active") }
    end
  end
end
