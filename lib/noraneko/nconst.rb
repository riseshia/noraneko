# frozen_string_literal: true

module Noraneko
  class NConst
    attr_accessor :included_module_names, :extended_module_names,
                  :registered_callbacks
    attr_reader :qualified_name, :namespace, :path

    def initialize(qualified_name, path, line)
      @qualified_name = qualified_name
      @namespace = qualified_name.split('::')
      @path = path
      @line = line
      @methods = []
      @included_module_names = []
      @extended_module_names = []
      @registered_callbacks = []
      @called_methods = []
      @default_scope = :public
      @default_type = :instance
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
      method.called_methods << called_method_name if method
    end

    def register_csend(called_method_name)
      @called_methods << called_method_name
    end

    def find_method(method_name)
      @methods.find do |method|
        method.name == method_name
      end
    end

    def private!
      @default_scope = :private
    end

    def method_default_as_class!
      @default_type = :class
    end

    def controller?
      false
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
      nmethod = NMethod.new(self, name, line, @default_scope, @default_type)
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
      target.private!
    end

    def merge_singleton(other)
      cm = other.all_instance_methods
      cm.each(&:class_method!)
      @methods += cm
    end

    def called?(target_name)
      @called_methods.any? { |name| name == target_name }
    end

    def used?(target_method)
      return true if registered_callback?(target_method.name)
      all_methods.any? { |method| method.called?(target_method.name) }
    end

    def self.build_nclass(qualified_name, filepath, line)
      klass =
        if qualified_name.end_with?('Controller')
          Noraneko::NController
        else
          Noraneko::NClass
        end

      klass.new(qualified_name, filepath, line)
    end

    private

    def registered_callback?(method_name)
      @registered_callbacks.any? { |name| name == method_name }
    end

    def qualify(names)
      names.join('::')
    end
  end
end
