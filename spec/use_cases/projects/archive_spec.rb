require "rails_helper"

describe Projects::Archive do
  let(:service) { described_class.new(project) }
  let(:project) { create(:project) }
  let(:clear_pending_service) do
    CheckAssignments::ClearPending.new(project: project)
  end

  describe "#call" do
    it "sets current date on archived_at field of passed project" do
      Timecop.freeze(Time.current) do
        expect { service.call }.to change { project.archived_at }
        expect(project.archived_at).to eq(Time.current)
      end
    end

    it "calls clear_pending method from CheckAssignments" do
      expect(CheckAssignments::ClearPending)
        .to receive(:new).with(project: project)
        .and_return(clear_pending_service)
      service.call
    end
  end
end
