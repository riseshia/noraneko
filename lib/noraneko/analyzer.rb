# frozen_string_literal: true

require 'parser/current'
# opt-in to most recent AST format:
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true

module Noraneko
  class Analyzer
    def execute(source)
      ast = Parser::CurrentRuby.parse(source)
      codes = LineOfCode.generate(source)
      Description.new(codes)
    end
  end
end
