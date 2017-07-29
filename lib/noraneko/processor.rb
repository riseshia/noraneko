# frozen_string_literal: true

require 'parser/current'
# opt-in to most recent AST format:
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true

module Noraneko
  class Processor < ::Parser::AST::Processor
    attr_writer :registry, :filepath, :scope

    def self.init_with(registry:, filepath: nil)
      new.tap do |instance|
        instance.registry = registry
        instance.filepath = filepath
        instance.scope = []
      end
    end

    def process(node)
      return nil unless node
      scope_generated = false

      case node.type
      when :class
        nclass = process_class(node)
        @scope << nclass.name
        scope_generated = true
      when :sclass
        nclass = process_class(node)
        @scope << nclass.name
        scope_generated = true
      when :module
        nmodule = process_module(node)
        @scope << nmodule.name
        scope_generated = true
      when :def
        process_def(node)
      when :defs
        process_defs(node)
      when :send
        process_send(node)
      end

      super

      if node.type == :sclass
        main_class_name = @scope[0..-2].join('::')
        main_class = @registry.find(main_class_name)
        main_class.merge_singleton(nclass)
        @registry.delete(nclass)
      end
      if scope_generated
        @scope.pop
        @public_scope = true
      end
    end

    private

    def process_class(node)
      qualified_name = if node.children.first.type == :self
                         @scope + %w[self]
                       else
                         @scope + const_to_arr(node.children.first)
                       end
      line = node.loc.line
      nclass = NClass.new(qualified_name.join('::'), @filepath, line)
      @registry.put(nclass)
    end

    def process_module(node)
      qualified_name = @scope + const_to_arr(node.children.first)
      line = node.loc.line
      nmodule = NModule.new(qualified_name.join('::'), @filepath, line)
      @registry.put(nmodule)
    end

    def process_def(node)
      qualified_name = @scope.join('::')
      nconst = @registry.find(qualified_name) || NModule.new('', @filepath, 0)

      method_name = node.children.first
      line = node.loc.line
      nmethod = NMethod.new(nconst, method_name, line)
      nconst.add_method(nmethod)
      @registry.put(nconst)
    end

    def process_defs(node)
      qualified_name = @scope.join('::')
      nconst = @registry.find(qualified_name) || NModule.new('', @filepath, 0)

      method_name = node.children[1]
      line = node.loc.line
      nmethod = NMethod.new(nconst, method_name, line)
      nconst.add_cmethod(nmethod)
      @registry.put(nconst)
    end

    def process_send(node)
      children = node.children
      case children[1]
      when :private
        process_private(node)
      when :include
        process_include(node)
      when :extend
      end
    end

    def process_include(node)
      node.children[2..-1].each do |target|
        const_name = const_to_arr(target).join('::')
        scope_nconst.included_module_names << const_name
      end
    end

    def process_private(node)
      if node.children.size == 2
        scope_nconst.scope = :private
      else
        method_name = node.children.last.children.first
        scope_nconst.make_method_private(method_name)
      end
    end

    def scope_nconst
      @registry.find(@scope.join('::'))
    end

    def const_to_arr(const_node, consts = [])
      next_const_node, const_sym = const_node.children
      consts.unshift(const_sym)
      if next_const_node
        const_to_arr(next_const_node, consts)
      else
        consts
      end
    end
  end
end
