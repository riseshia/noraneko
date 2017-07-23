# frozen_string_literal: true

module Noraneko
  class Project
    def initialize(descriptions)
      @descriptions = descriptions
    end

    def unused_methods
      []
    end
  end
end
