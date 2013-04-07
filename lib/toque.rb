require 'capistrano'

require 'toque/version'
require 'toque/helpers'
require 'toque/omnibus'
require 'toque/chef'

module Toque
  def self.load_into(configuration)
    Toque::Helpers.load_into configuration
    Toque::Omnibus.load_into configuration
    Toque::Chef.load_into configuration
  end
end

if Capistrano::Configuration.instance
  Toque.load_into(Capistrano::Configuration.instance)
end
