# frozen_string_literal: true

module Noraneko
  class NMethod
    attr_accessor :called_methods
    attr_reader :name, :line

    def initialize(nconst, name, line)
      @nconst = nconst
      @name = name
      @line = line
      @called_methods = []
    end

    def called?(other_name)
      @called_methods.include?(other_name)
    end

    def qualified_name
      @nconst.qualified_name + ' ' + @name
    end
  end
end
