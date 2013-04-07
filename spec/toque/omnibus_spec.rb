require 'spec_helper'

describe Toque::Omnibus, 'loaded into capistrano' do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend Capistrano::Spec::ConfigurationExtension
    Toque.load_into(@configuration)
  end

  it 'should define default omnibus installer URL' do
    expect(@configuration.fetch :chef_omnibus_installer_url).to be == 'http://www.opscode.com/chef/install.sh'
  end

  it "defines toque:omnibus:install task" do
    expect(@configuration.find_task 'toque:omnibus:install').to_not be_nil
  end

  describe 'toque:omnibus:install' do

    it 'should install chef using omnibus installer' do
      @configuration.find_and_execute_task 'toque:omnibus:install'
      expect(@configuration).to have_run("sudo -p 'sudo password: ' true && curl -L http://www.opscode.com/chef/install.sh | sudo -p 'sudo password: ' bash")
    end

    context 'with custom installer URL' do
      before { @configuration.set :chef_omnibus_installer_url, 'http://mysrv.tld/inst.sh' }

      it 'should install chef using custom omnibus installer' do
        @configuration.find_and_execute_task 'toque:omnibus:install'
        expect(@configuration).to have_run("sudo -p 'sudo password: ' true && curl -L http://mysrv.tld/inst.sh | sudo -p 'sudo password: ' bash")
      end
    end

    context 'with specific chef version' do
      before { @configuration.set :chef_version, '10.24.0' }

      it 'should install chef using custom omnibus installer' do
        @configuration.find_and_execute_task 'toque:omnibus:install'
        expect(@configuration).to have_run("sudo -p 'sudo password: ' true && curl -L http://www.opscode.com/chef/install.sh | sudo -p 'sudo password: ' bash -s -- -v 10.24.0")
      end
    end
  end
end
