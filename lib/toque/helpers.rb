module Toque

  # Toque helpers
  #
  module Helpers
    def self.load_into(configuration)
      configuration.load do

        namespace :toque do

          # Set toque default variable.
          #
          def set_default(variable, *args, &block)
            @_toque_variables ||= []
            @_toque_overridden ||= []
            @_toque_variables << variable
            if exists? variable
              @_toque_overridden << variable
            else
              set variable, *args, &block
            end
          end

          # Return toque remote working directory.
          #
          def pwd(*path)
            File.join(fetch(:toque_pwd).to_s, *path.map(&:to_s))
          end
          set_default :toque_pwd, '/tmp/toque'

          # Return toque remote working directory. Will be created remotely if not existing.
          #
          def pwd!(*path)
            run "mkdir -p #{pwd = pwd(*path)}"
            pwd
          end

          # Search if curl is present
          #
          def curl?
            run 'curl'
            true
          rescue ::Capistrano::CommandError
            false
          end

          # Install curl if not present
          #
          def require_curl
            sudo 'apt-get install --no-install-recommends -yq curl' unless curl?
          end

          desc 'List current toque configuration'
          task :config do
            @_toque_variables.sort_by(&:to_s).each do |name|
              display_name = ":#{name},".ljust(30)
              if variables[name].is_a?(Proc)
                value = "<block>"
              else
                value = fetch(name).inspect
                value = "#{value[0..40]}... (truncated)" if value.length > 40
              end
              overridden = @_toque_overridden.include?(name) ? " (overridden)" : ""
              puts "set #{display_name} #{value}#{overridden}"
            end
          end

        end
      end
    end
  end
end
