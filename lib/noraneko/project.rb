# frozen_string_literal: true

module Noraneko
  class Project
    RESERVED_METHODS = %i[initialize self].freeze

    def initialize(registry, view_registry)
      @registry = registry
      @nconsts = registry.to_a
      @view_registry = view_registry
      @views = view_registry.to_a
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

    def unused_views
      controllers = @nconsts.select { |n| n.controller? }
      @views.reject { |v| v.name == 'layouts/application' }.select do |view|
        controllers.none? { |con| con.used_view?(view.name) } &&
          @views.none? { |v| v.called?(view.name) }
      end
    end

    def all_unuseds
      unused_methods + unused_modules + unused_views
    end

    private

    def unused_private_methods
      methods = @nconsts.map(&:all_private_methods).flatten
      methods.each_with_object([]) do |method, candidates|
        # FIX: Inherit is not supported, so it handled as public method
        candidates << method if unused_public_method?(method)
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
