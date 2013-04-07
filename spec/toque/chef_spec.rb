require 'spec_helper'

describe Toque::Chef, 'loaded into capistrano' do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend Capistrano::Spec::ConfigurationExtension
    Toque.load_into(@configuration)
  end

  describe '#installed?' do
    it 'detect if chef-solo is not installed' do
      expect(@configuration.toque.chef.installed?).to be_false
    end

    it 'detect if chef-solo is installed' do
      @configuration.stub_command 'chef-solo -v || true', data: 'Chef 11.4.0'
      expect(@configuration.toque.chef.installed?).to be_true
    end
  end

  describe '#installed_version' do
    it 'should fetch installed chef version' do
      @configuration.stub_command 'chef-solo -v || true', data: 'Chef 11.4.0'
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

  describe '#upload_cookbooks' do
    before do
      File.stub(:exists?).and_return false
      File.stub(:exists?).with('config/cookbooks').and_return true
    end

    it 'should upload cookbooks' do
      @configuration.toque.chef.upload_cookbooks

      expect(@configuration).to have_uploaded.to('/tmp/toque/cookbooks.tar')
    end

    it 'should extract cookbooks on server' do
      @configuration.toque.chef.upload_cookbooks

      expect(@configuration).to have_run 'cd /tmp/toque && tar -xjf cookbooks.tar'
    end
  end
end
