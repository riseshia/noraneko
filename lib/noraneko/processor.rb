# frozen_string_literal: true

require 'parser/current'
# opt-in to most recent AST format:
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true

module Noraneko
  class Processor < ::Parser::AST::Processor
    attr_writer :registry, :filepath

    def self.init_with(registry:, filepath: nil)
      new.tap do |instance|
        instance.registry = registry
        instance.filepath = filepath
      end
    end

    def process(node)
      return nil unless node

      case node.type
      when :class then process_class(node)
      when :module then process_module(node)
      end

      super
    end

    private

    def process_class(node)
      name = const_to_str(node.children.first, [])
      line = node.loc.line
      nclass = NClass.new(name, @filepath, line)
      @registry.update_or_create(name, nclass)
    end

    def process_module(node)
      name = const_to_str(node.children.first, [])
      line = node.loc.line
      nmodule = NModule.new(name, @filepath, line)
      @registry.update_or_create(name, nmodule)
    end

    def const_to_str(const_node, consts)
      next_const_node, const_sym = const_node.children
      consts.unshift(const_sym)
      if next_const_node
        const_to_str(next_const_node, consts)
      else
        consts.map(&:to_s).join('::')
      end
    end
  end
end
