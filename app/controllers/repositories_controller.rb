# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :require_login
  before_action :set_repository, only: %i[show]

  def index
    @repositories = current_user.repositories.order(created_at: :desc)
  end

  def new
    @github_repositories = GithubClient.repos(current_user.token)
    @repository = current_user.repositories.build
  end

  def create
    github_id_param = params.require(:repository).fetch(:github_id)

    github_repo = GithubClient.repo(
      github_id: github_id_param.to_i,
      access_token: current_user.token
    )

    @repository = current_user.repositories.build(
      github_id: github_repo.id,
      name: github_repo.name,
      full_name: github_repo.full_name,
      language: github_repo.language,
      clone_url: github_repo.clone_url,
      ssh_url: github_repo.ssh_url
    )

    if @repository.save
      redirect_to repositories_path, notice: 'Репозиторий добавлен'
    else
      @github_repositories = GithubClient.repos(current_user.token)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @checks = @repository.checks.order(created_at: :desc)
  end

  private

  def set_repository
    @repository = current_user.repositories.find(params[:id])
  end
end
