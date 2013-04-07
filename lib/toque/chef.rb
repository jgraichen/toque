require 'tempfile'
require 'multi_json'

module Toque

  # Tasks and method to interact with chef.
  #
  module Chef
    def self.load_into(configuration)
      configuration.load do

        namespace :toque do
          namespace :chef do

            set_default :chef_omnibus_installer_url, 'http://www.opscode.com/chef/install.sh'
            set_default :cookbooks_paths, %w(config/cookbooks vendor/cookbooks)
            set_default :databags_path, 'config/databags'
            set_default :chef_version, '10.24.0'
            set_default :chef_debug, false
            set_default :chef_solo, '/opt/chef/bin/chef-solo'

            # Check if chef-solo installed on remote machine.
            #
            def installed?
              !installed_version.nil?
            end

            # Return installed chef-solo version.
            #
            def installed_version
              capture("#{chef_solo} -v || true") =~ /Chef: (\d+\.\d+\.\d+)/ ? $1 : nil
            end

            # Return path to chef solo executable.
            #
            def chef_solo
              fetch(:chef_solo).to_s || 'chef-solo'
            end

            # Return list of current recipes in run_list.
            #
            def recipes
              Array fetch(:run_list)
            end

            # Return list of existing cookbook paths.
            #
            def cookbooks_paths
              fetch(:cookbooks_paths).to_a.select { |path| File.exists? path }
            end

            # Abort if no existing cookbook paths are setted.
            #
            def ensure_cookbooks!
              raise 'No existing cookbook paths found.' if cookbooks_paths.empty?
            end

            # Return existing databag path or nil if path does not exist.
            #
            def databags_path
              File.exists?((path = fetch(:databags_path))) ? path : nil
            end

            # Create and return omnibus installer command
            #
            def install_command
              cmd = "#{top.sudo} bash"
              cmd += " -s -- -v #{required_version}" unless required_version.nil?
              cmd
            end

            # Return required chef version.
            #
            def required_version
              fetch(:chef_version) || nil
            end

            #
            # Tasks
            #

            desc 'Install chef via omnibus installed if not preset.'
            task :check do
              unless installed?
                logger.info "No chef install found. Install version #{required_version}."
                install
              end
              if (iv = installed_version) != required_version && !required_version.nil?
                logger.info "Wrong chef version found: #{iv}. Install version #{required_version}."
                install
              end
            end

            desc 'Installs chef using omnibus installer.'
            task :install do
              require_curl
              run "#{top.sudo} true && curl -L #{fetch :chef_omnibus_installer_url} | #{install_command}"
            end

            namespace :setup do
              desc 'Upload local cookbook to remote server.'
              task :cookbooks do
                pwd!

                tar = ::Tempfile.new("cookbooks.tar")
                begin
                  tar.close
                  system "tar -cjf #{tar.path} #{cookbooks_paths.join(' ')} #{databags_path.to_s}"
                  upload tar.path, toque.pwd("cookbooks.tar"), :via => :scp
                  run "cd #{toque.pwd} && tar -xjf cookbooks.tar"
                ensure
                  tar.unlink
                end
              end

              desc 'Generate and upload chef solo script.'
              task :script do
                pwd!

                cookbooks = cookbooks_paths.map { |p| %("#{pwd p}") }.join(', ')
                solo = <<-HEREDOC
                file_cache_path "#{pwd! 'cache'}"
                cookbook_path [ #{cookbooks} ]
                data_bag_path "#{pwd databags_path}"
                HEREDOC
                put solo, pwd("node.rb"), :via => :scp
              end

              desc 'Generate and upload node json configuration.'
              task :configuration do
                pwd!

                attrs = convert variables.dup
                attrs[:run_list] = recipes
                put MultiJson.dump(attrs), pwd("node.json"), :via => :scp
              end

              def convert(hash)
                hash.inject({}) do |attributes, element|
                  key, value = *element

                  begin
                    value = value.call    if value.respond_to? :call
                    value = convert value if value.is_a?(Hash)
                    value = nil           if value.class.to_s.include? 'Capistrano'
                    attributes[key] = value    unless value.nil?
                  rescue ::Capistrano::CommandError => error
                    logger.debug "Could not get the value of #{key}: #{error.message}"
                    nil
                  end

                  attributes
                end
              end
            end

            desc 'Run list of recipes from `:run_list` option.'
            task :run_list do
              ensure_cookbooks!

              check
              setup.cookbooks
              setup.script
              setup.configuration

              logger.info "Now running #{recipes.join(', ')}"

              sudo "#{chef_solo} -c #{pwd "node.rb"} -j #{pwd "node.json"}#{' -l debug' if fetch(:chef_debug)}"
            end

          end
        end

      end
    end
  end
end
