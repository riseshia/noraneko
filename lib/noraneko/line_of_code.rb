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

    def def_name
      if class_def? || module_def?
        @code.split(' ').last.split(';').first
      else
        throw 'This is not module def or class def'
      end
    end

    def comment?
      @code.start_with?('#')
    end

    def self.generate(source)
      source.each_line.map.with_index(1) do |line, line_number|
        new(line_number, line.strip)
      end
    end
  end
end
