module Noraneko
  class ViewProcessor
    def initialize(registry:, filepath:)
      @registry = registry
      @filepath = filepath
      @nview = Noraneko::NView.new(@filepath, :partial)
      registry.put(@nview)
    end

    def process(text)
      text.each_line do |line|
        process_line(line)
      end
    end

    private

    def process_line(line)
      matched = line.match(/\srender[\s(]+(['"])(.+)(\1)/)
      return unless matched
      @nview.call_view(matched[2])
    end
  end
end
