module Noraneko
  # Store information of line of code
  class LineOfCode
    def initialize(line_number, code)
      @line_number = line_number
      @code = code
    end

    def module_def?
      @code.start_with?('module ')
    end

    def class_def?
      @code.start_with?('class ')
    end

    def method_def?
      @code.start_with?('def ')
    end

    def private_keyword?
      @code == 'private'
    end

    def private_keyword_with_params?
      @code.start_with?('private ')
    end

    def private_keyword_params
      if private_keyword_with_params?
        normalized_params
      else
        throw 'This has no private keyword params'
      end
    end

    def def_name
      if class_def? || module_def? || method_def?
        @code.split(' ').last.split(';').first.split('(').first.split('.').last
      else
        throw 'This is not module def or class def'
      end
    end

    def include_module?
      @code.start_with?('include ')
    end

    def included_modules
      if include_module?
        normalized_params
      else
        throw 'This code is not for include'
      end
    end

    def extend_module?
      @code.start_with?('extend ')
    end

    def extended_modules
      if extend_module?
        normalized_params
      else
        throw 'This code is not for extend'
      end
    end

    def include?(method_name)
      @code.include?(method_name)
    end

    def self.generate(source)
      source.each_line.map.with_index(1) do |line, line_number|
        new(line_number, line.strip)
      end
    end

    private

    def normalized_params
      @code.split(' ')[1..-1].join('').split(',').map do |keyword|
        keyword.delete(":'\"")
      end
    end
  end
end
