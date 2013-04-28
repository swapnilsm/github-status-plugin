require_relative 'github_api'

class GithubStatus < Jenkins::Tasks::Publisher

  attr_reader :github_repo,
              :github_api,
              :github_username,
              :github_password

  display_name "Publish Jenkins job status to GitHub status API"

  # Invoked with the form parameters when this extension point
  # is created from a configuration screen.
  def initialize(attrs = {})
    puts attrs
    # Store each attr as an instance attribute.
    attrs.each do |k, v|
      instance_variable_set "@#{k}", v
    end
  end

  ##
  # Runs before the build begins
  #
  # @param [Jenkins::Model::Build] build the build which will begin
  # @param [Jenkins::Model::Listener] listener the listener for this build.
  def prebuild(build, listener)
    listener.info "GitHub status: pending"
  end

  ##
  # Runs the step over the given build and reports the progress to the listener.
  #
  # @param [Jenkins::Model::Build] build on which to run this step
  # @param [Jenkins::Launcher] launcher the launcher that can run code on the node running this build
  # @param [Jenkins::Model::Listener] listener the listener for this build.
  def perform(build, launcher, listener)
    jenkins_status = build.native.getResult.to_s
    listener.info "Jenkins status: #{jenkins_status}"
    gh_state = get_github_state(jenkins_status)
    listener.info "GitHub state: #{gh_state}"
  end

  ##
  # Verifies the user/pass can access the given repo.
  #
  # @param [String] FIXME
  # @param [String] FIXME
  # @param [String] FIXME
  # @param [String] FIXME
  def test_connection(github_repo, github_username, github_password, github_api)
    # FIXME!
    return true
  end

  private

  # Returns the state GitHub needs for the status API.
  #
  # @param [String] the build status
  def get_github_state(jenkins_status)
    if jenkins_status == 'SUCCESS'
      return 'success'
    else
      return 'failure'
    end
  end

end
