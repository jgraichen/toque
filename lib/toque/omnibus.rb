module Toque

  # Define tasks and method to check for existing chef installs
  # and to install chef using omnibus installer.
  #
  module Omnibus
    def self.load_into(configuration)
      configuration.load do

        namespace :toque do

          set_default :chef_omnibus_installer_url, 'http://www.opscode.com/chef/install.sh'

          namespace :omnibus do

            def omnibus_bash_cmd # :nodoc:
              cmd = "#{top.sudo} bash"
              cmd += " -s -- -v #{fetch :chef_version}" unless fetch(:chef_version) == :latest or fetch(:chef_version).nil?
              cmd
            end

            desc 'Installs chef using omnibus installer.'
            task :install do
              run "#{top.sudo} true && curl -L #{fetch :chef_omnibus_installer_url} | #{omnibus_bash_cmd}"
            end
          end
        end

      end
    end
  end
end
