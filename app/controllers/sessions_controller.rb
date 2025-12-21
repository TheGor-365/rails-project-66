class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    auth = request.env['omniauth.auth']

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

  def failure
    Rails.logger.warn("OmniAuth failure: message=#{params[:message].inspect} strategy=#{params[:strategy].inspect}")
    redirect_to root_path, alert: "GitHub login failed: #{params[:message]}"
  end
end
