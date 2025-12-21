# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']

    unless auth
      redirect_to root_path, alert: 'Ошибка авторизации через GitHub'
      return
    end

    user = User.find_or_initialize_by(email: auth['info']['email'])

    user.nickname  = auth['info']['nickname']
    user.name      = auth['info']['name']
    user.email     = auth['info']['email']
    user.image_url = auth['info']['image']
    user.token     = auth['credentials']['token']

    user.save!

    session[:user_id] = user.id
    redirect_to root_path, notice: 'Успешный вход через GitHub'
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'Вы вышли'
  end
end
