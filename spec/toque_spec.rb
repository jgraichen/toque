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

      task :awesome! do
        toque.run_list "recipe[awesomeium]"
      end

      task :awesome_the_second! do
        toque.run_list "recipe[awesomeium::second]"
      end
    end

    @configuration.sudo 'apt-get remove -yq curl'
    @configuration.sudo 'apt-get autoremove -yq'
  end

  after do
    #@vagrant.cli 'destroy', '--force'
  end

  it 'should write an awesome file' do
    @configuration.awesome!

    file_exists = @vagrant.primary_vm.channel.sudo 'ls /tmp/toque/awesome'
    expect(file_exists).to be == 0

    @configuration.awesome_the_second!

    file_exists = @vagrant.primary_vm.channel.sudo 'ls /tmp/toque/awesome', :error_check => false
    expect(file_exists).to_not be == 0
  end
end
