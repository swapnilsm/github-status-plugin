require 'json'
require 'rest-client'
require 'uri'

class GitHubApi

  ##
  # Create a new GitHubApi instance for interacting with GitHub.
  #
  # @param [String] github repo of the form <owner>/<repo_name>
  # @param [String] github API location, ie https://api.github.com
  # @param [String] github username for authenticating requests
  # @param [String] github password for authenticating requests
  def initialize(github_repo, github_api_url, github_username, github_password)
    @github_repo = github_repo
    @github_api_url = github_api_url
    @github_username = github_username
    @github_password = github_password
  end

  ##
  # Records the given state using the GitHub API.
  #
  # @param [String] the state to record against the commit
  # @param [String] the commit SHA1 that was built
  # @param [String] the URL for the build
  # @param [String] description of status
  def record_status(github_state, commit_sha, build_url, description, listener)
    begin
      url = statuses_url(commit_sha)

      # Remove password for logging.
      log_url = url.clone
      log_url.password = nil

      body = json_body(github_state, build_url, description)

      listener.debug("Making GitHub request to #{log_url.to_s} with body: #{body}")
      response = RestClient.post(url.to_s,
                                 body,
                                 :content_type => :json,
                                 :acceptn => :json)
      listener.info("Published status #{github_state} to GitHub repo: #{@github_repo}")
    rescue RestClient::Exception => e
      listener.error("Failed to POST status to GitHub: #{e.response} #{e}")
    rescue => e
      listener.error("Failed to POST status to GitHub: #{e}")
    end
  end

  private

  ##
  # Returns serialized JSON request body.
  #
  # @param [String] github state - one of pending, failure, success
  # @param [String] build url
  # @param [String] description to add to the status on github
  def json_body(github_state, build_url, description)
    return {
      :state => github_state,
      :target_url => build_url,
      :description => description
    }.to_json
  end

  # Returns URL for GitHub repo. URL is an instance of URI.
  def repo_url
    url = URI(@github_api_url)
    url.user = @github_username
    url.password = @github_password
    url.path = "/repos/#{@github_repo}"
    return url
   end

  ##
  # Returns URL for GitHub Status API. URL is an instance of URI.
  #
  # @param [String] the commit SHA1 that was built
  def statuses_url(commit_sha)
    url = repo_url
    url.path = "#{url.path}/statuses/#{commit_sha}"
    return url
  end

end
