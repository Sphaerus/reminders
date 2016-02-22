require "rails_helper"

describe ProjectChecksController do
  let(:user) { create(:admin) }
  let(:reminder) { create(:reminder) }
  let(:project_check) { create(:project_check, reminder: reminder) }

  before do
    allow(controller).to receive(:current_user) { user }
  end

  describe "#override_deadline" do
    let(:params) do
      { project_check_id: project_check.id, project_check_days_left: 10 }
    end
    subject { post :override_deadline, params }

    context "when user is an admin" do
      context "and days left value has to be changed" do
        before do
          allow_any_instance_of(ProjectChecks::OverrideDeadline)
            .to receive(:call).and_return(true)
        end

        it "calls service and renders notice" do
          subject
          expect(flash[:notice])
            .to have_text("All right! Initial due date changed!")
        end
      end

      context "and days left can't be changed beceuse of errors" do
        before do
          allow_any_instance_of(ProjectChecks::OverrideDeadline)
            .to receive(:call).and_return(false)
          allow_any_instance_of(ActiveModel::Errors)
            .to receive(:full_messages).and_return(["Unable to process"])
        end

        it "calls service and renders alert" do
          subject
          expect(flash[:alert])
            .to have_text("Unable to process")
        end
      end
    end

    context "when user is not an admin" do
      let(:user) { create(:user) }

      it "redirects to root path" do
        expect(subject).to redirect_to(root_path)
      end
    end
  end

  describe "#toggle_state" do
    let(:params) { { project_check_id: project_check.id } }
    subject { post :toggle_state, params }

    context "when user is an admin" do
      it "toggle project state" do
        expect { subject }.to change { project_check.reload.enabled }
          .from(true).to(false)
      end

      it "renders a notice" do
        subject
        expect(flash[:notice]).to have_text("All right!")
      end

      context "and state can't be changed beceuse of errors" do
        before do
          allow_any_instance_of(ProjectCheck)
            .to receive(:save).and_return(false)
          allow_any_instance_of(ActiveModel::Errors)
            .to receive(:full_messages).and_return(["Unable to process"])
        end

        it "renders alert" do
          subject
          expect(flash[:alert])
            .to have_text("Unable to process")
        end
      end
    end

    context "when user is not an admin" do
      let(:user) { create(:user) }

      it "doesn't toggle project state" do
        expect { subject }
          .not_to change { project_check.reload.enabled }
      end
    end
  end

  describe "#update" do
    let(:params) do
      {
        project_check: { info: "New info" },
        id: project_check.id,
      }
    end
    subject { post :update, params }

    it "updates project check info" do
      subject
      expect(project_check.reload.info).to eq("New info")
    end

    it "renders notice" do
      subject
      expect(flash[:notice]).to have_text("Check info updated.")
    end

    context "when project can't be saved because of errors" do
      before do
        allow_any_instance_of(ProjectChecks::Update)
          .to receive(:call).and_return(false)
        allow_any_instance_of(ActiveModel::Errors)
          .to receive(:full_messages).and_return(["Unable to process"])
      end

      it "renders alert" do
        subject
        expect(flash[:alert]).to have_text("Unable to process")
      end
    end
  end
end
