class ApplicationController < ActionController::Base
  decent_configuration do
    strategy DecentExposure::StrongParametersStrategy
  end
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :correct_user?
  helper_method :admin?

  before_action :authenticate_user!

  private

  def append_info_to_payload(payload)
    super
    payload[:request_id] = request.uuid
    payload[:user_id] = current_user.id if current_user.present?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def admin?
    current_user.present? && current_user.admin?
  end

  def user_signed_in?
    return true if current_user
  end

  def correct_user?
    @user = User.find(params[:id])
    redirect_to root_url, alert: "Access denied." unless current_user == @user
  end

  def authenticate_admin!
    return if admin?
    redirect_to root_url, alert: "You need to be admin to access to this page."
  end

  def authenticate_user!
    return if current_user.present?

    redirect_to root_url, alert: "You need to sign in for access to this page."
  end
end
