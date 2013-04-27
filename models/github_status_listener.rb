class Github_statusListener
  include Jenkins::Listeners::RunListener

  # Called when a build is started (i.e. it was in the queue, and will now start running
  # on an executor)
  #
  # @param [Jenkins::Model::Build] the started build
  # @param [Jenkins::Model::TaskListener] the task listener for this build
  def started(build, listener)
  end

  # Called after a build is completed.
  #
  # @param [Jenkins::Model::Build] the completed build
  # @param [Jenkins::Model::TaskListener] the task listener for this build
  def completed(build, listener)
  end

  # Called after a build is finalized.
  #
  # At this point, all the records related to a build is written down to the disk. As such,
  # task Listener is no longer available. This happens later than {#completed}.
  #
  # @param [Jenkins::Model::Build] the finalized build
  def finalized(build)
  end

  # Called right before a build is going to be deleted.
  #
  # @param [Jenkins::Model::Build] The build.
  def deleted(build)
  end
end
