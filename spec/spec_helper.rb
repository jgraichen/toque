require 'capistrano-spec'
require 'toque'

Dir[File.expand_path('spec/support/**/*.rb')].each {|f| require f}

RSpec.configure do |config|
  config.include Capistrano::Spec::Matchers
  config.include Capistrano::Spec::Helpers

  config.order = "random"

  config.expect_with :rspec do |c|
    # Only allow expect syntax
    c.syntax = :expect
  end
end
