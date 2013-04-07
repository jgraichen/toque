module Toque
  module Tasks
    def self.load_into(configuration)
      configuration.load do


        namespace :toque do

          def abc

          end

        end
      end
    end
  end
end
