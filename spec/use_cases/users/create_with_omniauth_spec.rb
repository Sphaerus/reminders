require "rails_helper"

describe Users::CreateWithOmniauth do
  let(:service) { described_class.new(auth: auth) }
  let(:auth) do
    {
      "provider" => "google",
      "uid" => "123",
      "info" => { "name" => "John", "email" => "john@doe.pl" },
    }
  end

  let(:user) { service.call }

  describe ".call" do
    it "creates user with provider" do
      expect(user.provider).to_not be_blank
      expect(user.provider).to eq(auth["provider"])
    end

    it "creates user with uid" do
      expect(user.uid).to_not be_blank
      expect(user.uid).to eq(auth["uid"])
    end

    it "creates user with email" do
      expect(user.email).to_not be_blank
      expect(user.email).to eq(auth["info"]["email"])
    end

    it "creates user with name" do
      expect(user.name).to_not be_blank
      expect(user.name).to eq(auth["info"]["name"])
    end
  end
end
