require 'spec_helper'

describe GithubStatusPublisher do
  context 'github status publisher' do
    # Setup stubs.
    let(:build) { stub }
    let(:launcher) { stub }
    let(:listener) { stub }
    let(:github_api) { stub }

    context '.perform' do
      before do
        GithubApi.stub(:new).and_return(github_api)
        build.stub(:native => stub(:get_absolute_url => 'my_url',
                                   :full_display_name => 'my_display_name',
                                   :getResult => 'SUCCESS'))
      end  # before

      it 'returns early when validate fails' do
        github_api.should_receive(:test_credentials).and_return(false)
        github_api.should_not_receive(:record_status)
        subject.perform(build, launcher, listener)
      end  # it

      it 'calls record_status with expected args when validate passes' do
        github_api.should_receive(:test_credentials).and_return(true)
        subject.stub(:sha1).and_return('my_sha1')
        github_api.should_receive(:record_status).with('success',
                                                       'my_sha1',
                                                       'my_url',
                                                       'my_display_name completed with status: SUCCESS',
                                                       listener)
        subject.perform(build, launcher, listener)
      end  # it
    end  # context

    context '.get_github_status' do
      it 'should return success when jenkins status is SUCCESS' do
        subject.send(:get_github_state, "SUCCESS").should eql("success")
      end

      it 'should return failure when jenkins status is not exactly SUCCESS' do
        ["FAILURE", "UNSTABLE", "ABORTED", "SUCCES", "success", nil, 5].each do |jenkins_status|
          subject.send(:get_github_state, jenkins_status).should eql("failure"), "Unexpected state when jenkins status is: #{jenkins_status}"
        end
      end
    end  # context

    context '.sha1' do
      it 'returns nil when run fails' do
        subject.stub(:run).and_return({:exit_code => 1, :out => 'my_stdout', :err => 'my_stderr'})
        listener.should_receive(:error).with(/my_stdout/).with(/my_stderr/)
        result = subject.send(:sha1, build, launcher, listener)
        result.should eql(nil)
      end  # it

      it 'returns stripped output when run succeeds' do
        subject.stub(:run).and_return({:exit_code => 0, :out => "\n\nmy_sha1\t\n", :err => ''})
        listener.should_receive(:debug).with(/my_sha1/)
        subject.should_receive(:run).with("git rev-parse HEAD",
                                          build,
                                          launcher,
                                          listener)
        result = subject.send(:sha1, build, launcher, listener)
        result.should eql('my_sha1')
      end  # it
    end  # context
  end  # context
end  # describe
