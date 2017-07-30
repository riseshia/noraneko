# frozen_string_literal: true

module Noraneko
  class NMethod
    attr_accessor :called_methods
    attr_reader :name, :line
    attr_writer :scope, :type

    def initialize(nconst, name, line, scope, type)
      @nconst = nconst
      @name = name
      @line = line
      @called_methods = []
      @scope = scope
      @type = type
    end

    def self.instance_method(nconst, name, line, scope = :public)
      new(nconst, name, line, scope, :instance)
    end

    def self.class_method(nconst, name, line)
      new(nconst, name, line, :public, :class)
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

    def in_public?
      @scope == :public
    end

    def in_private?
      !in_public?
    end

    def class_method?
      @type == :class
    end

    def instance_method?
      !class_method?
    end
  end
end
