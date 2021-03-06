require 'spec_helper'

describe Toque::Helpers, 'loaded into capistrano' do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend Capistrano::Spec::ConfigurationExtension
    Toque.load_into(@configuration)
  end

  describe '#pwd' do
    it 'return toque working dir' do
      expect(@configuration.toque.pwd).to be == '/tmp/toque'
    end

    it 'return custom path if set' do
      @configuration.set :toque_pwd, '/tmp/custom_path'
      expect(@configuration.toque.pwd).to be == '/tmp/custom_path'
    end
  end

  describe '#pwd!' do
    it 'return create remote working dir' do
      @configuration.toque.pwd!
      expect(@configuration).to have_run 'mkdir -p /tmp/toque'
    end
  end

  describe '#curl?' do
    it 'return true if curl exists' do
      @configuration.stub_command 'curl', data: "curl: try 'curl --help' or 'curl --manual' for more information"
      expect(@configuration.toque.curl?).to be_true
    end

    it 'return false if curl is missing' do
      @configuration.stub_command 'curl', fail: true
      expect(@configuration.toque.curl?).to be_false
    end
  end

  describe '#require_curl' do
    it 'should install curl if not present' do
      @configuration.stub_command 'curl', fail: true
      @configuration.stub_command "sudo -p 'sudo password: ' apt-get install --no-install-recommends -yq curl" do |_|
        @configuration.stub_command 'curl', data: "curl: try 'curl --help' or 'curl --manual' for more information"
      end

      expect(@configuration.toque.curl?).to be_false
      @configuration.toque.require_curl
      expect(@configuration.toque.curl?).to be_true
    end
  end
end
