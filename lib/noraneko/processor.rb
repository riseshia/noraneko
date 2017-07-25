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
        @scope << nclass.qualified_name
        scope_generated = true
      when :module
        nmodule = process_module(node)
        @scope << nmodule.qualified_name
        scope_generated = true
      end

      super

      @scope.pop if scope_generated
    end

    private

    def process_class(node)
      qualified_name = @scope + const_to_str(node.children.first)
      line = node.loc.line
      nclass = NClass.new(qualified_name.join('::'), @filepath, line)
      @registry.update_or_create(nclass)
    end

    def process_module(node)
      qualified_name = @scope + const_to_str(node.children.first)
      line = node.loc.line
      nmodule = NModule.new(qualified_name.join('::'), @filepath, line)
      @registry.update_or_create(nmodule)
    end

    def const_to_str(const_node, consts = [])
      next_const_node, const_sym = const_node.children
      consts.unshift(const_sym)
      if next_const_node
        const_to_str(next_const_node, consts)
      else
        consts
      end
    end
  end
end
