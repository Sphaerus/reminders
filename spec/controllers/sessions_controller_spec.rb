require "rails_helper"

describe SessionsController do
  context "create" do
    let(:params) { { provider: "google" } }
    subject { get :create, params }

    before do
      @request.env["omniauth.auth"] = auth
    end

    context "auth hash contains info" do
      let(:auth) do
        {
          "provider" => "google",
          "uid" => 123,
          "info" => { "name" => "John", "email" => "john@doe.pl" }
        }
      end

      it "render notice" do
        subject
        expect(flash).to be_present
        expect(flash[:notice]).to eq("Signed in!")
      end

      it "changes session" do
        expect { subject }.to change { session }
      end

      it "redirects to root" do
        expect(subject).to redirect_to(root_url)
      end
    end

    context "auth hash does not contain info" do
      let(:auth) do
        {
          "provider" => "google",
          "uid" => 123
        }
      end

      let(:failure_message) { "missing info date in the account." }

      it "redirect to failure" do
        expect(subject)
          .to redirect_to(auth_failure_url(message: failure_message))
      end
    end
  end
end
