# frozen_string_literal: true

module Noraneko
  class NConst
    attr_accessor :included_module_names, :extended_module_names
    attr_reader :qualified_name, :public_imethods, :private_imethods,
                :public_cmethods, :private_cmethods
    attr_writer :scope

    def initialize(qualified_name, path, line)
      @qualified_name = qualified_name
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

    def name
      @qualified_name.split('::').last
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

    def make_cmethod_private(name)
      targets, @public_cmethods =
        @public_cmethods.partition { |method| method.name == name }
      @private_cmethods.concat(targets)
    end

    def merge_singleton(other)
      @public_cmethods += other.public_imethods
      @private_cmethods += other.private_imethods
    end

    def merge(_other)
      throw 'this should be implemented'
    end
  end
end
