module Toque
  module Tasks
    def self.load_into(configuration)
      configuration.load do

        namespace :toque do

          # Run list of recipes. Install chef if not already preset.
          #
          def run_list(*recipes)
            omnibus.install unless chef.installed?
            chef.run_list *recipes
          end

        end

      end
    end
  end
end
