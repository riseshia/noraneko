# frozen_string_literal: true

module Noraneko
  class NConst
    attr_accessor :included_module_names, :extended_module_names
    attr_reader :qualified_name, :namespace, :path
    attr_writer :scope

    def initialize(qualified_name, path, line)
      @qualified_name = qualified_name
      @namespace = qualified_name.split('::')
      @path = path
      @line = line
      @methods = []
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
      @methods.find do |method|
        method.name == method_name
      end
    end

    def controller?
      name.end_with?('Controller')
    end

    def all_methods
      @methods
    end

    def all_instance_methods
      @methods.select { |method| method.instance_method? }
    end

    def all_private_methods
      @methods.select { |method| method.in_private? }
    end

    def all_public_methods
      @methods.select { |method| method.in_public? }
    end

    def all_used_modules
      @included_module_names + @extended_module_names
    end

    def add_method(name, line)
      nmethod = NMethod.instance_method(self, name, line, @scope)
      @methods << nmethod
      nmethod
    end

    def add_cmethod(name, line)
      nmethod = NMethod.class_method(self, name, line)
      @methods << nmethod
      nmethod
    end

    def make_method_private(name)
      target = @methods.find { |method| method.name == name }
      target.scope = :private
    end

    def merge_singleton(other)
      cm = other.all_instance_methods
      cm.each { |m| m.type = :class }
      @methods += cm
    end

    def used?(target_method)
      return true if controller? && action_of_this?(target_method)
      all_methods.any? { |method| method.called?(target_method.name) }
    end

    private

    def action_of_this?(target_method)
      target_method.in?(self)
    end

    def qualify(names)
      names.join('::')
    end
  end
end
