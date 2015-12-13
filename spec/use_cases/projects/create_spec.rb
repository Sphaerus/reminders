require "rails_helper"

describe Projects::Create do
  let(:attrs) { attributes_for(:project) }
  let(:projects_repo) { ProjectsRepository.new }
  let(:service) do
    described_class.new(attrs: attrs, projects_repo: projects_repo)
  end

  describe "#call" do
    context "with valid params" do
      it "creates the object" do
        expect { service.call }.to change { projects_repo.all.count }.by(1)
      end
    end

    context "with invalid params" do
      let(:attrs) { { name: "" }  }

      it "doesn't create object" do
        expect { service.call }.to_not change { projects_repo.all.count }
      end
    end
  end
end
