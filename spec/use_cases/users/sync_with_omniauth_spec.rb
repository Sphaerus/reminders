require "rails_helper"

describe Users::SyncWithOmniauth do
  let(:service) { described_class.new(user, auth) }
  let(:user) { create(:user, email: "johny@doe.pl") }
  let(:auth) do
    {
      "provider" => "google",
      "uid" => "123",
      "info" => { "name" => "John", "email" => "john@doe.pl" },
    }
  end

  describe "#call" do
    context "user's email is different from the one from auth" do
      it "changes user.email to the one from auth" do
        expect { service.call }.to change { user.email }
        expect(user.reload.email).to eq(auth["info"]["email"])
      end
    end
  end
end
