module Noraneko
  class Analyzer
    def execute(source)
      codes = LineOfCode.generate(source)

      if codes.first.class_def?
        Description.new(:class, codes)
      elsif codes.first.module_def?
        Description.new(:module, codes)
      else
        throw 'this source could not be handled'
      end
    end
  end
end
