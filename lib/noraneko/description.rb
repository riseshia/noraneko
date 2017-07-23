module Noraneko
  class Description
    attr_reader :type, :name,
                :defined_public_methods,
                :defined_private_methods,
                :extended_modules,
                :included_modules

    def initialize(type, codes)
      @type = type
      @codes = codes

      @defined_public_methods = []
      @defined_private_methods = []
      @extended_modules = []
      @included_modules = []

      build_context
    end

    private

    def build_context
      setup_scope

      public_scope = true
      be_private = []
      @codes.each do |code|
        if code.private_keyword?
          public_scope = false
        elsif code.private_keyword_with_params?
          code.private_keyword_params.each do |key|
            be_private << key
          end
        elsif code.method_def?
          if public_scope
            @defined_public_methods << code.def_name
          else
            @defined_private_methods << code.def_name
          end
        elsif code.include_module?
          @included_modules += code.included_modules
        elsif code.extend_module?
          @extended_modules += code.extended_modules
        end
      end

      be_private.each do |method_name|
        @defined_public_methods.delete(method_name)
        @defined_private_methods << method_name
      end

      @defined_public_methods.sort!
      @defined_private_methods.sort!
      @extended_modules.sort!
      @included_modules.sort!
    end

    def setup_scope
      code = @codes.find { |c| c.class_def? || c.module_def? }

      if code
        @name = code.def_name
      else
        throw 'This source has no module or class'
      end
    end
  end
end
