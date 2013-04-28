require 'json'
require 'rest-client'
require 'uri'

class GitHubApi

  ##
  # Create a new GitHubApi instance for interacting with GitHub.
  #
  # @param [GitHubStatus] instance of GitHub status with instance attributes
  # set.
  def initialize(github_status)
    @github_status = github_status
  end

  ##
  # Records the given state using the GitHub API.
  #
  # @param [String] the state to record against the commit
  # @param [String] the commit SHA1 that was built
  # @param [String] the URL for the build
  # @param [String] description of status
  def record_status(github_state, commit_sha, build_url, description, listener)
    url = statuses_url(commit_sha).to_s
    begin
      response = RestClient.post(url,
                                 json_body(github_state, build_url, description).to_json,
                                 :content_type => :json,
                                 :acceptn => :json)
      listener.info("Published status #{gihtub_state} to GitHub repo: #{github_status.github_repo}")
    rescue => e
      listener.error("Failed to POST status to GitHub: #{e}")
    end
  end

  private

  # Returns URL for GitHub repo. URL is an instance of URI.
  def repo_url
    api = @github_status.github_api
    user = @github_status.github_username
    pass = @github_status.github_password
    repo = @github_status.github_repo

    begin
      url = URI(api)
      url.user = user
      url.password = pass
      url.path = "/repos/#{repo}"
      return url
    rescue => e
      return nil
    end
   end

  ##
  # Returns URL for GitHub Status API. URL is an instance of URI.
  #
  # @param [String] the commit SHA1 that was built
  def statuses_url(commit_sha)
    begin
      url = repo_url
      url.path = "#{url.path}/statuses/#{commit_sha}"
      return url
    rescue => e
      return nil
    end
  end

end
