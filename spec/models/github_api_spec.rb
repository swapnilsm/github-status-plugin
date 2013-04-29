require 'spec_helper'

describe GithubApi do
  context 'github api' do
    # Setup stubs
    let(:listener) { stub(:debug => true) }

    subject { GithubApi.new('my_repo', 'http://api/github', 'my_username', 'my_password') }

    context '.record_status' do
      it 'logs error when request fails' do
        subject.stub(:statuses_url).and_return(URI('http://status'))
        subject.stub(:json_body).and_return('json_body')
        RestClient.stub(:post).and_raise(RestClient::Exception)

        listener.should_receive(:error).with(/RestClient/)
        subject.record_status('success', 'my_sha1', 'my_build_url', 'my_desc', listener)
      end  # it

      it 'logs error when exception occurs' do
        subject.stub(:statuses_url).and_return(URI('http://status'))
        subject.stub(:json_body).and_return('json_body')
        RestClient.stub(:post).and_raise(StandardError.new('my_error'))

        listener.should_receive(:error).with(/my_error/)
        subject.record_status('failure', 'my_sha1', 'my_build_url', 'my_desc', listener)
      end  # it

      it 'makes request to github when successful' do
        subject.stub(:statuses_url).and_return(URI('http://status'))
        subject.stub(:json_body).and_return('json_body')
        RestClient.stub(:post).and_return('my_response')

        listener.should_receive(:info).with(/my_repo/)
        subject.record_status('success', 'my_sha1', 'my_build_url', 'my_desc', listener)
      end  # it
    end  # context

    context '.test_credentials' do
      it 'returns false and logs error when request fails' do
        RestClient.stub(:get).and_raise(RestClient::Exception)
        listener.should_receive(:error).with(/RestClient/)
        subject.test_credentials(listener).should eql(false)
      end  # it

      it 'returns false and logs error when exception occurs' do
        RestClient.stub(:get).and_raise(StandardError.new('my_exception'))
        listener.should_receive(:error).with(/my_exception/)
        subject.test_credentials(listener).should eql(false)
      end  # it

      it 'returns true when request succeeds' do
        RestClient.stub(:get).and_return('{"some": "json", "stuff": true}')
        subject.test_credentials(listener).should eql(true)
      end  # it
    end  # context

    context '.json_body' do
      it 'returns a json hash of input parameters' do
        result = subject.send(:json_body, "my_gh_state", "http://my_build_url", "my_description")
        result.should eql('{"state":"my_gh_state","target_url":"http://my_build_url","description":"my_description"}')
      end  # it
    end  # context

    context '.repo_url' do
      it 'returns a URI based on instance attributes' do
        result = subject.send(:repo_url)
        result.to_s.should eql("http://my_username:my_password@api/github/repos/my_repo")
      end  # it
    end  # context

    context '.statuses_url' do
      it 'returns an extended repo_url' do
        subject.stub(:repo_url).and_return(URI('http://status/github'))
        result = subject.send(:statuses_url, 'my_sha1')
        result.to_s.should eql('http://status/github/statuses/my_sha1')
      end  # it
    end  # context
  end  # context
end  # describe
