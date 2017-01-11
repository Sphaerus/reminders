class AddLastCheckDateWithoutDisabledPeriodAndDisabledDateToProjectsChecks < ActiveRecord::Migration[5.0]
  def up
    add_column :project_checks, :last_check_date_without_disabled_period, :date
    add_column :project_checks, :disabled_date, :date
    ProjectCheck.where(enabled: false).each{ |pc| pc.update(disabled_date: pc.updated_at) }
  end

  def down
    remove_column :project_checks, :last_check_date_without_disabled_period, :date
    remove_column :project_checks, :disabled_date, :date
  end
end
