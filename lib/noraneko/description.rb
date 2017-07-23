module Noraneko
  class Description
    attr_reader :type, :name

    def initialize(type, codes)
      @type = type
      @codes = codes
      code = codes.find { |code| code.class_def? || module_def? }

      if code
        @name = code.def_name
      else
        throw 'This source has no module or class'
      end
    end

    def defined_public_instance_methods
      []
    end

    def defined_private_instance_methods
      []
    end

    def defined_public_class_methods
      []
    end

    def expanded_modules
      []
    end

    def included_modules
      []
    end
  end
end
