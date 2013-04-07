require 'capistrano'

require 'toque/version'
require 'toque/tasks'
require 'toque/omnibus'

module Toque
  def self.load_into(configuration)
    Toque::Tasks.load_into configuration
    Toque::Omnibus.load_into configuration
  end
end

if Capistrano::Configuration.instance
  Toque.load_into(Capistrano::Configuration.instance)
end
