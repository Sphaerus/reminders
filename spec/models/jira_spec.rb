require "rails_helper"

RSpec.describe Jira do
  let(:project) { double :project, id: 3, name: "Unique project" }
  let(:jira) { Jira.new(project: project) }

  describe ".create_issue_from_project" do
    it "creates instance and calls create_issue_from_project method" do
      expect(described_class).to receive(:new).with(project: project).and_return(jira)
      expect_any_instance_of(described_class).to receive(:create_issue_from_project).with(no_args)
      described_class.create_issue_from_project(project: project)
    end
  end

  describe "#create_issue_from_project" do
    subject { jira.create_issue_from_project }

    let(:config) { AppConfig.jira }
    let(:endpoint) { config.endpoint }
    let(:response) { double :response, body: { key: "RD-X" }.to_json, code: 201 }
    let(:jira_username) { "jira_user" }
    let(:jira_password) { "jira_pass" }
    let(:authorization) { "Basic #{Base64.strict_encode64("#{jira_username}:#{jira_password}")}" }

    let(:params) do
      {
        fields: {
          project: { key: config.project_key },
          issuetype: { name: config.issue_type },
          summary: "#{config.summary} #{project.name}",
        }
      }
    end
    let(:headers) do
      {
        content_type: :json,
        accept: :json,
        authorization: authorization,
      }
    end

    context "when jira is enabled" do
      around do |example|
        AppConfig["jira"]["username"] = jira_username
        AppConfig["jira"]["password"] = jira_password

        previous = AppConfig["jira"]["enabled?"]
        AppConfig["jira"]["enabled?"] = true
        example.run
        AppConfig["jira"]["enabled?"] = previous
        AppConfig["jira"]["username"] = nil
        AppConfig["jira"]["password"] = nil
      end

      it "sends request to jira endpoint and returns parsed response" do
        expect(RestClient).to receive(:post)
                                .with("#{endpoint}/issue", params.to_json, headers)
                                .and_return(response)
        expect(subject).to eq("key" => "RD-X")
      end
    end

    context "when jira is not enabled" do
      around do |example|
        previous = AppConfig["jira"]["enabled?"]
        AppConfig["jira"]["enabled?"] = false
        example.run
        AppConfig["jira"]["enabled?"] = previous
      end

      it "logs the information" do
        expect(Rails.logger).to receive(:info).with("Jira params: #{params}")
        subject
      end

      it "returns false" do
        expect(subject).to eq(false)
      end
    end
  end
end
