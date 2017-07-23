# frozen_string_literal: true

module Noraneko
  class Project
    def initialize(descriptions)
      @descriptions = descriptions
    end

    def unused_methods
      find_unused_private + unused_public_methods
    end

    private

    def find_unused_private
      @descriptions.each_with_object([]) do |desc, candidates|
        desc.defined_private_methods.each do |method|
          candidates << method unless desc.using?(method)
        end
      end
    end

    def unused_public_methods
      methods = @descriptions.map(&:defined_public_methods).flatten
      methods.each_with_object([]) do |method, candidates|
        candidates << method if unused_public_method?(method)
      end
    end

    def unused_public_method?(method_name)
      @descriptions.none? { |desc| desc.using?(method_name) }
    end
  end
end
