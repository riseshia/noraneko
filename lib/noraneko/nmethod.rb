# frozen_string_literal: true

module Noraneko
  class NMethod
    attr_reader :name, :line

    def initialize(nconst, name, line)
      @nconst = nconst
      @name = name
      @line = line
    end
  end
end
