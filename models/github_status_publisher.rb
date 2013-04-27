# A single build step that run after the build is complete
class GithubStatusPublisher < Jenkins::Tasks::Publisher

  display_name "Publish Jenkins job status to GitHub status API"

  # Invoked with the form parameters when this extension point
  # is created from a configuration screen.
  def initialize(attrs = {})
  end

  ##
  # Runs before the build begins
  #
  # @param [Jenkins::Model::Build] build the build which will begin
  # @param [Jenkins::Model::Listener] listener the listener for this build.
  def prebuild(build, listener)
    puts "GitHub status: pending"
  end

  ##
  # Runs the step over the given build and reports the progress to the listener.
  #
  # @param [Jenkins::Model::Build] build on which to run this step
  # @param [Jenkins::Launcher] launcher the launcher that can run code on the node running this build
  # @param [Jenkins::Model::Listener] listener the listener for this build.
  def perform(build, launcher, listener)
    jenkins_status = build.native.getResult.to_s
    puts "Jenkins status: #{jenkins_status}"
    gh_state = get_github_state(jenkins_status)
    puts "GitHub state: #{gh_state}"
  end

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
