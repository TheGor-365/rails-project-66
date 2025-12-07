class RepositoriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @repositories = current_user.repositories.order(:full_name)
  end

  def new
    @repository = current_user.repositories.new
    load_github_repositories
  end

  def create
    github_id = repository_params[:github_id].presence

    unless github_id
      @repository = current_user.repositories.new
      load_github_repositories
      flash.now[:alert] = "Выберите репозиторий"
      return render :new, status: :unprocessable_entity
    end

    repo_data = octokit_client.repository(github_id.to_i)

    @repository = current_user.repositories.new(
      github_id: repo_data.id,
      name: repo_data.name,
      full_name: repo_data.full_name,
      language: repo_data.language,
      clone_url: repo_data.clone_url,
      ssh_url: repo_data.ssh_url
    )

    if @repository.save
      redirect_to repositories_path, notice: "Репозиторий успешно добавлен"
    else
      load_github_repositories
      flash.now[:alert] = "Не удалось сохранить репозиторий"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def repository_params
    params.require(:repository).permit(:github_id)
  end

  def octokit_client
    @octokit_client ||= Octokit::Client.new(access_token: current_user.token)
  end

  def load_github_repositories
    repos = octokit_client.repos(nil, per_page: 100)
    @github_repositories = repos.select { |repo| repo.language == "Ruby" }
  end
end
