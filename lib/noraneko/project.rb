# frozen_string_literal: true

module Noraneko
  class Project
    def initialize(registry)
      @nconsts = registry.to_a
    end

    def unused_methods
      unused_private_methods + unused_public_methods
    end

    private

    def unused_private_methods
      @nconsts.each_with_object([]) do |nconst, candidates|
        nconst.all_private_methods.each do |method|
          candidates << method unless nconst.used?(method)
        end
      end
    end

    def unused_public_methods
      methods = @nconsts.map(&:all_public_methods).flatten
      methods.each_with_object([]) do |method, candidates|
        candidates << method if unused_public_method?(method)
      end
    end

    def unused_public_method?(method)
      @nconsts.none? { |nconst| nconst.used?(method) }
    end
  end
end
