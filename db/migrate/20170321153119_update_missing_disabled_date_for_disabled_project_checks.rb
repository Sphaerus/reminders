class UpdateMissingDisabledDateForDisabledProjectChecks < ActiveRecord::Migration[5.0]
  def up
    ProjectCheck.where(enabled: false, disabled_date: nil).each do |pc|
      pc.update(disabled_date: pc.updated_at)
    end
  end
end
