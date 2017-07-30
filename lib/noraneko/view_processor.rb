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

      name =
        if matched[2].split('/').size == 1
          rel_path_from_view + '/_' + matched[2]
        else
          matched[2].split('/').insert(-2, '_').join('')
        end

      @nview.call_view(name)
    end

    def rel_path_from_view
      @nview.filepath
        .split('/views/').drop(1).join('')
        .split('/')[0..-2].join('')
    end
  end
end
