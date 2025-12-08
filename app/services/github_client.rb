class GithubClient
  def self.repos(access_token)
    client(access_token).repos(per_page: 100)
  end

  def self.repo(github_id:, access_token:)
    normalized =
      if github_id.is_a?(Integer)
        github_id
      elsif github_id.to_s.match?(/\A\d+\z/)
        github_id.to_i
      else
        github_id
      end

    client(access_token).repo(normalized)
  end

  def self.client(access_token)
    Octokit::Client.new(access_token: access_token)
  end
end
