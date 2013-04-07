module Toque
  module VERSION
    MAJOR = 1
    MINOR = 5
    PATCH = 0
    STAGE = nil

    STRING = [MAJOR, MINOR, PATCH, STAGE].reject(&:nil?).join('.')

    def self.to_s; STRING end
  end
end
