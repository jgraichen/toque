require 'vagrant'

set :application, 'awesomeium'

set :repository, '.'
set :scm,        :none # not recommended in production
set :deploy_via, :copy

server '192.168.33.10', :web, :app, :db, :primary => true

set :user, 'vagrant'
set :password, 'vagrant' # not recommended in production

set :deploy_to, "/home/#{user}/#{application}"

set :use_sudo, false
default_run_options[:pty] = true

# Toque options
set :cookbooks_paths, %w(spec/config/cookbooks)

namespace :vagrant do
  task :up do
    Vagrant::Environment.new.cli 'up'
  end

  task :destroy do
    Vagrant::Environment.new.cli 'destroy'
  end
end

task :spec do
  toque.run_list "recipe[awesomeium]"
end
before 'spec', 'vagrant:up'
