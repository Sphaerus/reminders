require "rails_helper"

describe Projects::SyncWithDataGuru do
  let(:project) do
    double(:project, id: 1, name: "baz", channel_name: "project-baz",
                     email: "baz-team@foo.pl")
  end
  let(:data_guru_projects) do
    [double(display_name: "Foo", slack_project_channel_name: "project-foo"),
    double(display_name: "bar", slack_project_channel_name: "project-bar")]
  end
  let(:projects_repository) do
    class InMemoryProjectsRepository < InMemoryRepository
      def find_by_name(name)
        all.find { |r| r.name == name }
      end
    end
    repo = InMemoryProjectsRepository.new
    repo.all = [project]
    repo
  end
  let(:service) do
    described_class.new projects_repository
  end

  before do
    AppConfig["domain"] = "foo.pl"
    allow_any_instance_of(DataGuruClient).to receive_message_chain("data_guru.projects.all")
                                             .and_return data_guru_projects
  end

  describe "#call" do
    it "creates new projects" do
      expect { service.call }.to change { projects_repository.all.count }.by(2)
    end

    it "creates new projects and saves display name" do
      service.call
      expect(projects_repository.all.map(&:name))
        .to include("Foo", "bar", "baz")
    end

    it "creates new projects and saves channel name" do
      service.call
      expect(projects_repository.all.map(&:channel_name))
        .to include("project-foo", "project-bar", "project-baz")
    end

    it "creates new projects with emails based on project's names" do
      service.call
      expect(projects_repository.all.map(&:email))
        .to include("foo-team@foo.pl", "bar-team@foo.pl", "baz-team@foo.pl")
    end
  end
end
