require "rails_helper"

describe CheckAssignments::ResolveAction do
  let(:service) do
    described_class.new(assignment: assignment,
                        creator: creator,
                        completer: completer,
                       )
  end
  let(:creator) do
    CheckAssignments::CreateCompleted.new(
      checker: double(:user),
      project_check: double(:project_check),
      assignments_repository: repo,
      contact_person: create(:admin),
    )
  end
  let(:completer) do
    CheckAssignments::Complete.new(
      assignment: double(:assignment, project_check: nil),
      checker: double(:user),
      project_check: double(:project_check),
    )
  end

  let(:repo) { InMemoryRepository.new }

  describe "#can_create?" do
    context "when assignment is nil" do
      let(:assignment) { nil }

      it "returns true" do
        expect(service.can_create?).to be true
      end
    end

    context "with completed assignment" do
      let(:assignment) { double(:assignment, completion_date: "2015-06-06") }

      it "returns true" do
        expect(service.can_create?).to be true
      end
    end

    context "with uncompleted assignment" do
      let(:assignment) { double(:assignment, completion_date: nil) }

      it "returns false" do
        expect(service.can_create?).to be false
      end
    end
  end

  describe "#resolve" do
    let(:assignment) { double(:assignment) }

    before do
      allow(creator).to receive(:call)
      allow(completer).to receive(:call)
    end

    context "when new assignment can be created" do
      before do
        allow(service).to receive(:can_create?)
          .and_return(true)
      end

      it "makes call to assignment creator" do
        service.resolve
        expect(creator).to have_received(:call)
        expect(completer).not_to have_received(:call)
      end
    end

    context "when assignment should be completed" do
      before do
        allow(service).to receive(:can_create?)
          .and_return(false)
      end

      it "makes call to assignment completer" do
        service.resolve
        expect(completer).to have_received(:call)
        expect(creator).not_to have_received(:call)
      end
    end
  end
end
