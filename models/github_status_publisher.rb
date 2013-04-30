require 'stringio'

# require_relative would be better, but might as well support ruby 1.8.
require File.expand_path('../github_api', __FILE__)

class GithubStatusPublisher < Jenkins::Tasks::Publisher

  attr_reader :github_repo,
              :github_api_url,
              :github_username,
              :github_password

  display_name "Publish Jenkins job status to GitHub"

  # Invoked with the form parameters when this extension point
  # is created from a configuration screen.
  def initialize(attrs = {})
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
  end

  ##
  # Runs the step over the given build and reports the progress to the listener.
  #
  # @param [Jenkins::Model::Build] build on which to run this step
  # @param [Jenkins::Launcher] launcher the launcher that can run code on the node running this build
  # @param [Jenkins::Model::Listener] listener the listener for this build.
  def perform(build, launcher, listener)
    # Exit early if validation fails.
    if not validate(listener)
      return nil
    end

    commit_sha = sha1(build, launcher, listener)
    build_url = build.native.get_absolute_url
    build_name = build.native.full_display_name
    jenkins_status = build.native.getResult.to_s
    gh_state = get_github_state(jenkins_status)
    description = "#{build_name} completed with status: #{jenkins_status}"
    gh_api.record_status(gh_state, commit_sha, build_url, description, listener)
  end

  private

  ##
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

  # Returns a new instance of GithubApi from instance attributes.
  def gh_api
    return GithubApi.new(@github_repo,
                         @github_api_url,
                         @github_username,
                         @github_password)
  end

  ##
  # Execute a command in the workspace using the launcher.
  #
  # @param [String] command to execute
  # @param [Jenkins::Model::Build] build on which to run this step
  # @param [Jenkins::Launcher] launcher the launcher that can run code on the node running this build
  # @param [Jenkins::Model::Listener] listener the listener for this build.
  def run(command, build, launcher, listener)
    listener.debug("Executing command #{command} in workspace.")

    # Set the repo as the working dir, output stream handlers, and input
    # stream.
    opts = {
      :chdir => build.workspace.realpath,
      :out   => StringIO.new,
      :err   => StringIO.new,
      :in    => StringIO.new,
    }

    exit_code = launcher.execute(command, opts)

    # Rewind stdout/stderr streams
    opts[:out].rewind
    opts[:err].rewind

    # Return outputs and exit code.
    return {
      :exit_code => exit_code,
      :out       => opts[:out].read,
      :err       => opts[:err].read
    }
  end

  ##
  # Total hackery to retrieve the commit SHA1. Ideally, it would be something
  # like:
  #
  #   build.native.get_action(BuildData.class).get_last_built_revision.get_sha1
  #
  # But, as of 2013-04-27, I can't figure out how to import the BuildData class
  # from the git plugin.
  #
  # @param [Jenkins::Model::Build] build on which to run this step
  # @param [Jenkins::Launcher] launcher the launcher that can run code on the node running this build
  # @param [Jenkins::Model::Listener] listener the listener for this build.
  def sha1(build, launcher, listener)
    result = run("git rev-parse HEAD", build, launcher, listener)
    if result[:exit_code] == 0
      sha1 = result[:out].strip
      listener.debug("Current commit SHA1: #{sha1}")
      return sha1
    else
      listener.error("Failed to retrieve commit SHA1: stdout: #{result[:out]} stderr: #{result[:err]}")
      return nil
    end
  end

  ##
  # Validates that instance credentials are valid. Returns true if so. Logs an
  # error and returns false if not.
  #
  # @param [Jenkins::Model::Listener] listener the listener for this build.
  def validate(listener)
    return gh_api.test_credentials(listener)
  end

end
