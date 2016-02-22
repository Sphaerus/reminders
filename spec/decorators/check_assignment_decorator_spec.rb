require "rails_helper"

describe CheckAssignmentDecorator do
  let(:check_assignment) { OpenStruct.new }
  let(:decorator) { described_class.new(check_assignment) }

  describe "#assigned_days_ago_as_string" do
    context "assigned today" do
      it "returns today" do
        check_assignment.created_at = 0.days.ago
        expect(decorator.assigned_days_ago_as_string)
          .to eq("less than a minute ago")
      end
    end

    context "assigned yesterday" do
      it "returns 1 day ago" do
        check_assignment.created_at = 1.day.ago
        expect(decorator.assigned_days_ago_as_string).to eq("1 day ago")
      end
    end

    context "assigned 5 days ago" do
      it "returns 5 days ago" do
        check_assignment.created_at = 5.days.ago
        expect(decorator.assigned_days_ago_as_string).to eq("5 days ago")
      end
    end
  end

  describe "#row_class" do
    context "completion_date is present" do
      it "returns class active" do
        check_assignment.completion_date = Time.current
        expect(decorator.row_class).to eq("active")
      end
    end

    context "completion_date is not present" do
      it "returns nil" do
        check_assignment.completion_date = false
        expect(decorator.row_class).to be_nil
      end
    end
  end
end
