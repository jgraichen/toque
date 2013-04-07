require 'spec_helper'

describe Toque::Chef, 'loaded into capistrano' do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend Capistrano::Spec::ConfigurationExtension
    Toque.load_into(@configuration)
  end

  it 'should define default omnibus installer URL' do
    expect(@configuration.fetch :chef_omnibus_installer_url).to be == 'http://www.opscode.com/chef/install.sh'
  end

  it "defines toque:chef:install task" do
    expect(@configuration.find_task 'toque:chef:install').to_not be_nil
  end

  describe '#installed?' do
    it 'detect if chef-solo is not installed' do
      expect(@configuration.toque.chef.installed?).to be_false
    end

    it 'detect if chef-solo is installed' do
      @configuration.stub_command '/opt/chef/bin/chef-solo -v || true', data: 'Chef: 11.4.0'
      expect(@configuration.toque.chef.installed?).to be_true
    end
  end

  describe '#installed_version' do
    it 'should fetch installed chef version' do
      @configuration.stub_command '/opt/chef/bin/chef-solo -v || true', data: 'Chef: 11.4.0'
      expect(@configuration.toque.chef.installed_version).to be == '11.4.0'
    end
  end

  describe '#cookbooks_paths' do
    it 'should return existing cookbook paths' do
      File.stub(:exists?).with('config/cookbooks').and_return true
      File.stub(:exists?).with('vendor/cookbooks').and_return false

      expect(@configuration.toque.chef.cookbooks_paths).to be == %w(config/cookbooks)
    end
  end

  describe '#ensure_cookbooks!' do
    it 'should abort if no cookbook path exist' do
      File.stub(:exists?).with('config/cookbooks').and_return false
      File.stub(:exists?).with('vendor/cookbooks').and_return false

      expect{ @configuration.toque.chef.ensure_cookbooks! }.to raise_error
    end
  end

  describe '#databags_path' do
    it 'should return path if exists' do
      File.stub(:exists?).with('config/databags').and_return true

      expect(@configuration.toque.chef.databags_path).to be == 'config/databags'
    end

    it 'should return nit if path does not exists' do
      File.stub(:exists?).with('config/databags').and_return false

      expect(@configuration.toque.chef.databags_path).to be_nil
    end
  end

  describe '#chef_solo' do
    it 'should return path to chef solo executable' do
      expect(@configuration.toque.chef.chef_solo).to be == '/opt/chef/bin/chef-solo'
    end

    it 'should return path to custom chef solo executable' do
      @configuration.set :chef_solo, 'chef-solo'
      expect(@configuration.toque.chef.chef_solo).to be == 'chef-solo'
    end
  end

  describe 'toque:chef:setup:cookbooks' do
    before do
      File.stub(:exists?).and_return false
      File.stub(:exists?).with('config/cookbooks').and_return true
    end

    it 'should create working dir' do
      @configuration.toque.chef.setup.cookbooks

      expect(@configuration).to have_run 'mkdir -p /tmp/toque'
    end

    it 'should upload cookbooks' do
      @configuration.toque.chef.setup.cookbooks

      expect(@configuration).to have_uploaded.to('/tmp/toque/cookbooks.tar')
    end

    it 'should extract cookbooks on server' do
      @configuration.toque.chef.setup.cookbooks

      expect(@configuration).to have_run 'cd /tmp/toque && tar -xjf cookbooks.tar'
    end
  end

  describe 'toque:chef:setup:script' do
    it 'should upload chef solo script' do
      @configuration.toque.chef.setup.script

      expect(@configuration).to have_uploaded.to('/tmp/toque/node.rb')
    end
  end

  describe 'toque:chef:setup:configuration' do
    before do
      @configuration.set :run_list, %w(recipe[awesomeium])
      @configuration.set :postgres, :version => '9.2', password: -> { { postgresql: 'secret_in_proc' } }
      @configuration.toque.chef.setup.configuration
      @node = MultiJson.load @configuration.uploads.keys.first.read
    end

    it 'should upload node configuration' do
      expect(@configuration).to have_uploaded.to('/tmp/toque/node.json')
    end

    it 'should have called option procs' do
      expect(@node['postgres']['password']).to be == { 'postgresql' => 'secret_in_proc' }
    end
  end

  describe 'toque:chef:install' do
    it 'should install chef using omnibus installer' do
      @configuration.toque.chef.install
      expect(@configuration).to have_run("sudo -p 'sudo password: ' true && curl -L http://www.opscode.com/chef/install.sh | sudo -p 'sudo password: ' bash -s -- -v 10.24.0")
    end

    context 'with custom installer URL' do
      before { @configuration.set :chef_omnibus_installer_url, 'http://mysrv.tld/inst.sh' }

      it 'should install chef using custom omnibus installer' do
        @configuration.toque.chef.install
        expect(@configuration).to have_run("sudo -p 'sudo password: ' true && curl -L http://mysrv.tld/inst.sh | sudo -p 'sudo password: ' bash -s -- -v 10.24.0")
      end
    end

    context 'with specific chef version' do
      before { @configuration.set :chef_version, '10.24.0' }

      it 'should install chef using custom omnibus installer' do
        @configuration.toque.chef.install
        expect(@configuration).to have_run("sudo -p 'sudo password: ' true && curl -L http://www.opscode.com/chef/install.sh | sudo -p 'sudo password: ' bash -s -- -v 10.24.0")
      end
    end
  end

  describe 'toque:chef:check' do
    it 'should install chef using omnibus installer if not present' do
      @configuration.toque.chef.check
      expect(@configuration).to have_run("sudo -p 'sudo password: ' true && curl -L http://www.opscode.com/chef/install.sh | sudo -p 'sudo password: ' bash -s -- -v 10.24.0")
    end
  end
end
