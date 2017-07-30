# frozen_string_literal: true

module Noraneko
  class Project
    RESERVED_METHODS = %i[initialize self].freeze

    def initialize(registry)
      @nconsts = registry.to_a
      @registry = registry
    end

    def unused_methods
      (unused_private_methods + unused_public_methods).reject do |method|
        RESERVED_METHODS.include?(method.name)
      end
    end

    def unused_modules
      @nconsts.each_with_object([]) do |nconst, candidates|
        nconst.all_used_modules.each do |m_name|
          cmodule = @registry.find(m_name)
          next unless cmodule
          if cmodule.all_methods.all? { |method| unused_public_method?(method) }
            candidates << cmodule
          end
        end
      end
    end

    def all_unuseds
      unused_methods + unused_modules
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
