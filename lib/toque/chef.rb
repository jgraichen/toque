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

            # Check if chef-solo installed on remote machine.
            #
            def installed?
              !installed_version.nil?
            end

            # Return installed chef-solo version.
            #
            def installed_version
              capture('chef-solo -v || true') =~ /Chef (\d+\.\d+\.\d+)/ ? $1 : nil
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
              ensure_cookbooks!

              tar = Tempfile.new("cookbooks.tar")
              begin
                tar.close
                system "tar -cjf #{tar.path} #{cookbooks_paths.join(' ')} #{databags_path.to_s}"
                upload tar.path, toque.pwd!("cookbooks.tar"), :via => :scp
                run "cd #{toque.pwd} && tar -xjf cookbooks.tar"
              ensure
                tar.unlink
              end
            end

          end
        end

      end
    end
  end
end