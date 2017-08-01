# frozen_string_literal: true

require 'parser/current'

# opt-in to most recent AST format:
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true

module Noraneko
  class Processor < ::Parser::AST::Processor
    include Noraneko::NodeUtility

    attr_writer :registry, :filepath, :context_stack

    ParseError = Class.new(StandardError)

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

      begin
        case node.type
        when :class, :sclass
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
        when :block_pass
          process_block_pass(node)
        end
      rescue StandardError
        line = node.loc.line
        message = "Fail to parse. location: #{@filepath}:#{line}"
        raise ParseError.new(message)
      end

      super

      if node.type == :sclass
        @registry.find(nclass.parent_name).merge_singleton(nclass)
        @registry.delete(nclass)
      end
      if context_generated
        @public_scope = true unless in_method?
        @context_stack.pop
      end
    end

    private

    def process_class(node)
      names = if singleton_class?(node)
                %w[Self]
              else
                extract_consts(node.children.first)
              end
      qualified_name = current_context.child_qualified_name(names)
      line = node.loc.line
      nclass = NClass.new(qualified_name, @filepath, line)
      @context_stack << nclass
      @registry.put(nclass)
    end

    def process_module(node)
      names = extract_consts(node.children.first)
      qualified_name = current_context.child_qualified_name(names)
      line = node.loc.line
      nmodule = NModule.new(qualified_name, @filepath, line)
      @context_stack << nmodule
      @registry.put(nmodule)
    end

    def process_def(node)
      method_name = node.children.first
      line = node.loc.line
      nmethod = current_context.add_method(method_name, line)
      @context_stack << nmethod
    end

    def process_defs(node)
      method_name = node.children[1]
      line = node.loc.line
      nmethod = current_context.add_cmethod(method_name, line)
      @context_stack << nmethod
    end

    def process_send(node)
      case node.children[1]
      when :private
        process_private(node)
      when :include
        process_include(node)
      when :extend
        process_extend(node)
      when :alias_method
        process_alias_method(node)
      when :send
        process_explicit_send(node)
      else
        if in_method?
          process_send_message(node)
        else
          process_send_nconst(node)
        end
      end
    end

    def process_alias_method(node)
      aliased = node.children[2].children.last
      line = node.loc.line
      nmethod = current_context.add_method(aliased, line)
    end

    def process_external_import(node)
      node.children.drop(2).each_with_object([]) do |target, consts|
        if target.type == :const
          const_name = extract_consts(target).join('::')
          consts << const_name
        end
      end
    end

    def process_include(node)
      current_context.included_module_names += process_external_import(node)
    end

    def process_extend(node)
      current_context.extended_module_names += process_external_import(node)
    end

    def process_private(node)
      if node.children.size == 2
        current_context.private!
      else
        extract_syms(node.children.drop(2)).each do |method_name|
          current_context.make_method_private(method_name)
        end
      end
    end

    def process_send_nconst(node)
      case node.children[1]
      when :module_function
        syms = extract_syms(node.children[2..-1])
        if syms.empty?
          current_context.method_default_as_class!
        else
          syms.each { |sym| current_context.find_method(sym).class_method! }
        end
      when :layout
        process_layout(node)
      else
        current_context.register_csend(node.children[1])
        process_callback_register(node)
      end
    end

    def process_layout(node)
      param = node.children[2]
      if [:str, :sym].include?(param.type)
        layout = param.children.last.to_s
        current_context.called_view('layouts/' + layout)
      end
    end

    def process_callback_register(node)
      return if node.children.size < 3 || !node.children.first.nil?
      name = node.children[1]
      syms = node.children.drop(2).select { |n| n.type == :sym }
      return if syms.empty?
      current_context.registered_callbacks += extract_syms(syms)
    end

    def process_explicit_send(node)
      target_node= node.children[2]
      return unless [:str, :sym].include?(target_node.type)
      called_method_name = target_node.children.last.to_sym
      current_method_name = current_context.name
      parent_context.register_send(current_method_name, called_method_name)
    end

    def process_send_message(node)
      if parent_context.controller? && node.children[1] == :render
        process_render(node)
      else
        current_method_name = current_context.name
        called_method_name = node.children[1]
        parent_context.register_send(current_method_name, called_method_name)
      end
    end

    def process_block_pass(node)
      sym = node.children.first
      current_method_name = current_context.name
      called_method_name = sym.children.last
      parent_context.register_send(current_method_name, called_method_name)
    end

    def process_render(node)
      params = node.children.drop(2).first
      return unless params
      view_name = extract_view_name(params)
      return unless view_name
      parent_context.called_view(view_name)
    end

    def rel_path_from_controller(controller)
      controller.path
        .split('/controllers/').drop(1).join('')
        .split('_controller.rb').first + '/'
    end

    def extract_view_name(param)
      value =
        if param.type == :hash
          hash = convert_to_hash(param)
          hash[:action] || hash[:template]
        else
          param.children.last
        end
      # Inline render
      return nil unless value

      view_path = value.to_s.split('.').first
      if view_path.split('/').size == 1
        parent_context.rel_path_from_controller + view_path
      else
        view_path
      end
    end

    def parent_context
      @context_stack[-2] || global_const
    end

    def current_context
      @context_stack.last || global_const
    end

    def in_method?
      current_context.is_a? Noraneko::NMethod
    end

    def global_const
      return @_global_nconst if @_global_nconst
      @_global_nconst = NModule.new('', @filepath, 0)
      @registry.put(@_global_nconst)
    end
  end
end
