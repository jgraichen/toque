require 'spec_helper'
require 'vagrant'

describe Toque do

  before do
    @vagrant = Vagrant::Environment.new
    @vagrant.cli 'up'

    @configuration = Capistrano::Configuration.new
    Toque.load_into(@configuration)

    @configuration.load do

      server '192.168.33.10', :web, :app, :db, :primary => true
      set :user, 'vagrant'
      set :password, 'vagrant'

      set :use_sudo, false
      default_run_options[:pty] = true

      # Toque options
      set :cookbooks_paths, %w(spec/config/cookbooks)
      set :chef_version, '10.24.0'

      task :awesome! do
        toque.run_list 'recipe[awesomeium]'
      end

      task :awesome_the_second! do
        toque.run_list 'recipe[awesomeium::second]'
      end
    end

    @configuration.sudo 'apt-get remove -yq curl'
    @configuration.sudo 'apt-get autoremove -yq'
  end

  it 'should write an awesome file' do
    @configuration.awesome!

    # should have installed chef version
    expect(@configuration.capture('/opt/chef/bin/chef-solo -v').strip).to be == 'Chef: 10.24.0'

    # should have executed cookbook and created an awesome file
    file_exists = @vagrant.primary_vm.channel.sudo 'ls /tmp/toque/awesome'
    expect(file_exists).to be == 0

    @configuration.awesome_the_second!

    file_exists = @vagrant.primary_vm.channel.sudo 'ls /tmp/toque/awesome', :error_check => false
    expect(file_exists).to_not be == 0
  end
end
