require 'spec_helper'

RSpec.describe Noraneko::Description do
  let(:source) do
    <<-EOC
    class SimpleClass
      def used_public
        external_method
        used_private
      end

      def hige
        used_public + 1
      end

      private

      def used_private
      end

      def unused_private
      end
    end
    EOC
  end

  let(:description) { Noraneko::Analyzer.new.execute(source) }

  context '#using?' do
    context 'with used method' do
      %w[external_method used_public used_private].each do |method_name|
        it 'returns true' do
          expect(description.using?(method_name)).to eq(true)
        end
      end
    end

    context 'with unused method' do
      %w[unused_public unused_private].each do |method_name|
        it 'returns false' do
          expect(description.using?(method_name)).to eq(false)
        end
      end
    end
  end
end
