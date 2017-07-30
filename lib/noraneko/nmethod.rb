# frozen_string_literal: true

module Noraneko
  class NMethod
    attr_accessor :called_methods
    attr_reader :name, :line
    attr_writer :scope

    def initialize(nconst, name, line, scope = :public)
      @nconst = nconst
      @name = name
      @line = line
      @called_methods = []
      @scope = scope
    end

    def loc
      "#{@nconst.path}:#{@line}"
    end

    def in?(nconst)
      nconst.qualified_name == @nconst.qualified_name
    end

    def called?(other_name)
      @called_methods.include?(other_name)
    end

    def qualified_name
      delimiter = in_public? ? '.' : '#'
      "#{@nconst.qualified_name}#{delimiter}#{@name}"
    end

    private

    def in_public?
      @scope == :public
    end
  end
end
