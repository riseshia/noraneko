# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::Analyzer do
  let(:source) do
    <<-EOS
    class A::B < C
      def hoge
        a.b.c.d
      end

      private

      def hige; end
    end
    EOS
  end

  it 'parses source' do
    ast = Parser::CurrentRuby.parse(source)
    # Noraneko::Processor.new.process(ast)
  end
end
