# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # В тестах/деве это ломает интеграционные запросы (406 Not Acceptable),
  # а школе не нужно. Ограничиваем только продом.
  allow_browser versions: :modern if Rails.env.production?

  helper_method :current_user

  private

  def current_user
    return @current_user if defined?(@current_user)

@current_user = User.find_by(id: session[:user_id])
  end

  def require_login
    return if current_user

    redirect_to root_path
  end

  def authenticate_user!
    return if current_user

    redirect_to root_path, alert: 'Необходимо войти через GitHub'
  end
end
