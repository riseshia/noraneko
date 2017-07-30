# frozen_string_literal: true

module Noraneko
  class NConst
    attr_accessor :included_module_names, :extended_module_names
    attr_reader :qualified_name, :public_imethods, :private_imethods,
                :public_cmethods, :private_cmethods, :namespace, :path
    attr_writer :scope

    def initialize(qualified_name, path, line)
      @qualified_name = qualified_name
      @namespace = qualified_name.split('::')
      @path = path
      @line = line
      @public_imethods = []
      @private_imethods = []
      @private_cmethods = []
      @public_cmethods = []
      @included_module_names = []
      @extended_module_names = []
      @scope = :public
    end

    def loc
      "#{@path}:#{@line}"
    end

    def name
      @namespace.last || ''
    end

    def parent_name
      qualify(@namespace[0..-2])
    end

    def child_qualified_name(names)
      qualify(@namespace + names)
    end

    def register_send(method_name, called_method_name)
      method = find_method(method_name)
      method.called_methods << called_method_name
    end

    def find_method(method_name)
      (all_public_methods + all_private_methods).find do |method|
        method.name == method_name
      end
    end

    def controller?
      name.end_with?('Controller')
    end

    def all_methods
      all_private_methods + all_public_methods
    end

    def all_private_methods
      @private_imethods + @private_cmethods
    end

    def all_public_methods
      @public_imethods + @public_cmethods
    end

    def all_used_modules
      @included_module_names + @extended_module_names
    end

    def add_method(method)
      if @scope == :public
        @public_imethods << method
      else
        @private_imethods << method
      end
    end

    def add_cmethod(method)
      @public_cmethods << method
    end

    def make_method_private(name)
      targets, @public_imethods =
        @public_imethods.partition { |method| method.name == name }
      @private_imethods.concat(targets)
    end

    def merge_singleton(other)
      @public_cmethods += other.public_imethods
      @private_cmethods += other.private_imethods
    end

    def used?(target_method)
      all_methods.any? { |method| method.called?(target_method.name) }
    end

    private

    def qualify(names)
      names.join('::')
    end
  end
end
