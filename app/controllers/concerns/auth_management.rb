# frozen_string_literal: true

module AuthManagement
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  def require_login!
    return if current_user

    redirect_to root_path
  end

  def authenticate_user!
    return if current_user

    redirect_to root_path, alert: t('flash.auth.login_required')
  end
end
