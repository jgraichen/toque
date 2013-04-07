module Toque

  # Tasks and method to interact with chef.
  #
  module Chef
    def self.load_into(configuration)
      configuration.load do

        namespace :toque do
          namespace :chef do

            set_default :cookbooks_paths, %w(config/cookbooks vendor/cookbooks)
            set_default :databags_path, 'config/databags'
            set_default :chef_version, :latest
            set_default :chef_solo, '/opt/chef/bin/chef-solo'
            set_default :chef_debug, false

            # Check if chef-solo installed on remote machine.
            #
            def installed?
              !installed_version.nil?
            end

            # Return installed chef-solo version.
            #
            def installed_version
              capture("#{chef_solo} -v || true") =~ /Chef (\d+\.\d+\.\d+)/ ? $1 : nil
            end

            def chef_solo
              fetch(:chef_solo).to_s || 'chef-solo'
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

            # Upload cookbooks to remote server.
            #
            def upload_cookbooks
              pwd!

              tar = Tempfile.new("cookbooks.tar")
              begin
                tar.close
                system "tar -cjf #{tar.path} #{cookbooks_paths.join(' ')} #{databags_path.to_s}"
                upload tar.path, toque.pwd("cookbooks.tar"), :via => :scp
                run "cd #{toque.pwd} && tar -xjf cookbooks.tar"
              ensure
                tar.unlink
              end
            end

            # Generate and upload chef solo script
            #
            def upload_script
              cookbooks = cookbooks_paths.map { |p| %("#{pwd p}") }.join(', ')
              solo = <<-HEREDOC
                file_cache_path "#{pwd! 'cache'}"
                cookbook_path [ #{cookbooks} ]
                data_bag_path "#{pwd databags_path}"
              HEREDOC
              put solo, pwd("solo.rb"), :via => :scp
            end

            # Generate and upload node configuration
            #
            def upload_configuration(*recipes)
              attrs = variables.dup
              attrs[:run_list] = recipes
              put attrs.to_json, pwd("node.json"), :via => :scp
            end

            # Runs a list of recipes.
            #
            def run_list(*recipes)
              ensure_cookbooks!
              pwd!

              upload_script
              upload_configuration *recipes

              logger.info "Now running #{recipes.join(', ')}"

              sudo "#{chef_solo} -c #{pwd "solo.rb"} -j #{pwd "solo.json"}#{' -l debug' if fetch(:chef_debug)}"
            end

          end
        end

      end
    end
  end
end
