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
end
