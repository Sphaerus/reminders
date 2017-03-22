require "rails_helper"
require File.join(Rails.root,
                  "db",
                  "migrate",
                  "20170321153119_update_missing_disabled_date_for_disabled_project_checks.rb")

describe UpdateMissingDisabledDateForDisabledProjectChecks do
  let(:migration) { described_class.new }
  let(:enabled) { create(:project_check, enabled: true) }
  let(:disabled) { create(:project_check, enabled: false, disabled_date: 1.month.ago) }
  let(:disabled_nil) { create(:project_check, enabled: false, disabled_date: nil) }

  describe "#up" do
    context "when project check is enabled" do
      it "doesn't change anything" do
        expect { migration.up }.not_to change { ProjectCheck.all }
      end
    end

    context "when project check is disabled" do
      context "and has no disabled_date" do
        it "sets disabled_date to updated_at" do
          expect { migration.up }
            .to change { disabled_nil.reload.disabled_date }
            .to disabled_nil.updated_at.to_date
        end
      end

      context "and has a disabled_date" do
        it "doesn't change anything" do
          expect { migration.up }.not_to change { ProjectCheck.all }
        end
      end
    end
  end
end
