require "rails_helper"

describe SyncMissingProjectsJob do
  let(:job) do
    described_class.new(
      projects_repo: projects_repository,
      reminders_repo: reminders_repository,
      checks_repo: checks_repository,
    )
  end

  let(:reminder1) do
    double(:reminder, id: 1, projects: [],
                      project_checks: [])
  end

  let(:reminder2) do
    double(:reminder, id: 2, projects: [],
                      project_checks: [])
  end

  let(:reminders_repository) do
    repo = InMemoryRepository.new
    repo.all = [reminder1, reminder2]
    repo
  end

  let(:projects_repository) do
    class InMemoryProjectsRepository < InMemoryRepository
      def find_by_name(name)
        all.find { |r| r.name == name }
      end

      def for_reminder(_reminder)
        []
      end
    end
    InMemoryProjectsRepository.new
  end

  let(:checks_repository) do
    class InMemoryChecksRepository < InMemoryRepository
      def for_reminder(reminder)
        records.values.select { |r| r.reminder_id == reminder.id }
      end
    end
    InMemoryChecksRepository.new
  end

  let(:data_guru_projects) do
    [double(display_name: "One", slack_project_channel_name: "project-one"),
    double(display_name: "Two", slack_project_channel_name: "project-two")]
  end

  describe "#perform" do
    before do
      allow_any_instance_of(DataGuruClient).to receive_message_chain("data_guru.projects.all")
                                               .and_return data_guru_projects
    end

    it "creates project" do
      expect { job.perform }.to change { projects_repository.all.count }.by(2)
    end

    it "synchronises new projects with existing reminders" do
      expect { job.perform }
        .to change { checks_repository.for_reminder(reminder1).count }.by(2)
      expect { job.perform }
        .to change { checks_repository.for_reminder(reminder2).count }.by(2)
    end
  end
end
