module Toque
  module Tasks
    def self.load_into(configuration)
      configuration.load do

        namespace :toque do

          # Run list of recipes. Install chef if not already preset.
          #
          def run_list(*recipes)
            set :run_list, recipes
            chef.run_list
          end

        end

      end
    end
  end
end
