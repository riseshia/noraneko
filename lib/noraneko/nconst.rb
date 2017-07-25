# frozen_string_literal: true

module Noraneko
  class NConst
    attr_reader :qualified_name, :public_imethods, :private_imethods
    attr_writer :scope

    def initialize(qualified_name, path, line)
      @qualified_name = qualified_name
      @path = path
      @line = line
      @public_imethods = []
      @private_imethods = []
      @scope = :public
    end

    def add_method(method, scope = nil)
      if @scope == :public
        @public_imethods << method
      else
        @private_imethods << method
      end
    end

    def make_method_private(name)
      targets, @public_imethods =
        @public_imethods.partition { |method| method.name == name }
      @private_imethods.concat(targets)
    end

    def merge(_other)
      throw 'this should be implemented'
    end
  end
end
