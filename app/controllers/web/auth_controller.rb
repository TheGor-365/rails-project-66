# frozen_string_literal: true

module Web
  class AuthController < Web::ApplicationController
    def create
      auth = request.env["omniauth.auth"]

      unless auth
        redirect_to root_path, alert: "Ошибка авторизации через GitHub"
        return
      end

      user = User.find_or_initialize_by(email: auth.dig("info", "email"))

      user.nickname  = auth.dig("info", "nickname")
      user.name      = auth.dig("info", "name")
      user.email     = auth.dig("info", "email")
      user.image_url = auth.dig("info", "image")
      user.token     = auth.dig("credentials", "token")

      user.save!

      session[:user_id] = user.id
      redirect_to root_path, notice: "Успешный вход через GitHub"
    end

    def destroy
      session[:user_id] = nil
      redirect_to root_path, notice: "Вы вышли"
    end

    def failure
      Rails.logger.warn(
        %(OmniAuth failure: message="#{params[:message]}" strategy="#{params[:strategy]}")
      )

      redirect_to root_path, alert: "Не удалось войти через GitHub"
    end
  end
end
