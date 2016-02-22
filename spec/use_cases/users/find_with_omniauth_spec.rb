require "rails_helper"

describe Users::FindWithOmniauth do
  let(:service) { described_class.new(auth: auth) }
  let(:auth) do
    {
      "provider" => "google",
      "uid" => "123",
      "info" => { "name" => "John", "email" => "john@doe.pl" },
    }
  end

  describe ".call" do
    context "different email in auth and in user" do
      let!(:user) do
        create(:user, provider: "google", uid: "123", email: "johny@doe.pl")
      end

      it "does not care of email and finds user only with provider and uid" do
        expect(service.call).to eq(user)
      end
    end

    context "has the same uid but different provider" do
      let!(:user) do
        create(:user, provider: "facebook", uid: "123")
      end

      it "returns nil" do
        expect(service.call).to be_nil
      end
    end
  end
end
