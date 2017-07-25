# frozen_string_literal: true

module Noraneko
  class NConst
    attr_reader :qualified_name
    attr_accessor :public_imethods

    def initialize(qualified_name, path, line)
      @qualified_name = qualified_name
      @path = path
      @line = line
      @public_imethods = []
    end

    def merge(_other)
      throw 'this should be implemented'
    end
  end
end
