# frozen_string_literal: true

module Noraneko
  class NClass < ::Noraneko::NConst
    def initialize(name, path, line)
      @name = name
      @path = path
      @line = line
    end
  end
end
