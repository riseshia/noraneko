# frozen_string_literal: true

require 'parser/current'
# opt-in to most recent AST format:
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true

module Noraneko
  class Processor < ::Parser::AST::Processor
    attr_writer :registry, :filepath, :context_stack

    def self.init_with(registry:, filepath: nil)
      new.tap do |instance|
        instance.registry = registry
        instance.filepath = filepath
        instance.context_stack = []
      end
    end

    def process(node)
      return nil unless node
      context_generated = false

      case node.type
      when :class
        nclass = process_class(node)
        context_generated = true
      when :sclass
        nclass = process_class(node)
        context_generated = true
      when :module
        nmodule = process_module(node)
        context_generated = true
      when :def
        process_def(node)
        context_generated = true
      when :defs
        process_defs(node)
        context_generated = true
      when :send
        process_send(node)
      end

      super

      if node.type == :sclass
        @registry.find(nclass.parent_name).merge_singleton(nclass)
        @registry.delete(nclass)
      end
      if context_generated
        @context_stack.pop
        @public_scope = true unless in_method?
      end
    end

    private

    def process_class(node)
      names = if node.children.first.type == :self
                %w[Self]
              else
                const_to_arr(node.children.first)
              end
      qualified_name = current_context.child_qualified_name(names)
      line = node.loc.line
      nclass = NClass.new(qualified_name, @filepath, line)
      @context_stack << nclass
      @registry.put(nclass)
    end

    def process_module(node)
      names = const_to_arr(node.children.first)
      qualified_name = current_context.child_qualified_name(names)
      line = node.loc.line
      nmodule = NModule.new(qualified_name, @filepath, line)
      @context_stack << nmodule
      @registry.put(nmodule)
    end

    def process_def(node)
      method_name = node.children.first
      line = node.loc.line
      nmethod = NMethod.new(current_context, method_name, line)
      current_context.add_method(nmethod)
      @context_stack << nmethod
    end

    def process_defs(node)
      method_name = node.children[1]
      line = node.loc.line
      nmethod = NMethod.new(current_context, method_name, line)
      current_context.add_cmethod(nmethod)
      @context_stack << nmethod
    end

    def process_send(node)
      children = node.children
      case children[1]
      when :private
        process_private(node)
      when :include
        process_include(node)
      when :extend
        process_extend(node)
      else
        if in_method?
          process_send_message(node)
        end
      end
    end

    def process_include(node)
      node.children[2..-1].each do |target|
        const_name = const_to_arr(target).join('::')
        current_context.included_module_names << const_name
      end
    end

    def process_extend(node)
      node.children[2..-1].each do |target|
        const_name = const_to_arr(target).join('::')
        current_context.extended_module_names << const_name
      end
    end

    def process_private(node)
      if node.children.size == 2
        current_context.scope = :private
      else
        method_name = node.children.last.children.first
        current_context.make_method_private(method_name)
      end
    end

    def process_send_message(node)
      current_method_name = current_context.name
      called_method_name = node.children[1]
      nconst = parent_context
      nconst.register_send(current_method_name, called_method_name)
    end

    def parent_context
      @context_stack[-2] || global_const
    end

    def current_context
      @context_stack.last || global_const
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

    def in_method?
      start_char = (current_context || global_const).name
      start_char == start_char.downcase
    end

    def global_const
      return @_global_nconst if @_global_nconst
      @_global_nconst = NModule.new('', @filepath, 0)
      @registry.put(@_global_nconst)
    end
  end
end
