module Noraneko
  class Analyzer
    def execute(source)
      codes = LineOfCode.generate(source)

      Description.new(codes)
    end
  end
end
