require "rails_helper"

describe Project do
  describe "ActiveModel validations" do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:channel_name) }
    it { should validate_presence_of(:name) }
  end

  # workaround for issue connected to not-null unique values
  # https://github.com/thoughtbot/shoulda-matchers/issues/600
  it "validates uniqueness of name" do
    FactoryGirl.create(:project)
    should validate_uniqueness_of(:name)
  end
end
