require "rails_helper"

describe UsersRepository do
  let(:repo) { described_class.new }

  describe "#all" do
    before do
      2.times { create(:user) }
    end

    it "returns all users" do
      expect(repo.all.count).to eq 2
    end
  end

  describe "#from_auth" do
    let(:auth) do
      {
        "provider" => "google",
        "uid" => 123,
        "info" => { "name" => "John", "email" => "john@doe.pl" },
      }
    end

    context "when user exists" do
      let(:user) { create(:user, provider: "google", uid: 123) }

      it "returns user with given auth data" do
        expect(repo.from_auth(auth)).to be_an_instance_of User
      end
    end

    context "when user doesn't exist" do
      it "it creates new user and returns it" do
        expect(repo.all.count).to eq 0
        expect(repo.from_auth(auth)).to be_an_instance_of User
        expect(repo.all.count).to eq 1
      end
    end
  end

  describe "#toggle_admin" do
    context "user is admin" do
      let(:user) { create(:user, admin: true) }
      it "changes user.admin to false" do
        repo.toggle_admin(user.id)
        expect(user.reload.admin).to be_falsey
      end
    end

    context "user is not admin" do
      let(:user) { create(:user, admin: false) }
      it "changes user.admin to true" do
        repo.toggle_admin(user.id)
        expect(user.reload.admin).to be_truthy
      end
    end
  end

  describe "#toggle_paused" do
    context "user is paused" do
      let(:user) { create(:user, paused: true) }
      it "change value of paused to false" do
        repo.toggle_paused(user.id)
        expect(user.reload.paused).to be_falsy
      end
    end

    context "user is not paused" do
      let(:user) { create(:user, paused: false) }
      it "change value of paused to false" do
        repo.toggle_paused(user.id)
        expect(user.reload.paused).to be_truthy
      end
    end
  end

  describe "#active" do
    before do
      2.times { create(:user, archived_at: Time.current) }
      2.times { create(:user, archived_at: nil) }
    end

    it "returns only not archived users" do
      expect(repo.active.count).to eq(2)
      repo.active.each do |user|
        expect(user.archived_at).to be_nil
      end
    end
  end

  describe "#find_by_email" do
    let(:user) { create(:user, email: "john@doe.pl") }

    it "returns user with specified email" do
      expect(repo.find_by_email(user.email)).to eq(user)
    end
  end

  describe "#add" do
    let(:params) { { name: "John", email: "john@doe.pl" } }

    it "creates with attributes passed" do
      added_user = repo.add(params)
      expect(added_user.name).to eq(params[:name])
      expect(added_user.email).to eq(params[:email])
    end

    it "creates new user" do
      expect { repo.add(params) }.to change { User.count }.by(1)
    end
  end

  describe "#find_by" do
    let!(:user) { create(:user, uid: "123", provider: "google") }
    let(:attrs) { { uid: "123", provider: "google" } }

    it "returns user with specified attrs" do
      expect(repo.find_by(attrs)).to eq(user)
    end
  end
end
