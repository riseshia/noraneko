# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::Project do
  context '#unused_methods' do
    subject { project.unused_methods }
    let(:project) { described_class.new(descriptions) }
    let(:descriptions) { sources.map { |s| Noraneko::Analyzer.new.execute(s) } }

    context 'in class' do
      context 'with not used private method' do
        let(:source) do
          <<-EOS
          class A
            private
            def hoge
            end
          end
          EOS
        end
        let(:sources) { [source] }

        it { is_expected.to include('hoge') }
      end

      context 'with used private method' do
        let(:source) do
          <<-EOS
          class A
            def hoge
              hige
            end
            private
            def hige
            end
          end
          EOS
        end
        let(:sources) { [source] }

        it { is_expected.not_to include('hige') }
      end

      context 'with used private method with private keyword' do
        let(:source) do
          <<-EOS
          class A
            def hoge
              hige
            end
            def hige
            end
            private :hige
          end
          EOS
        end
        let(:sources) { [source] }

        it do
          skip 'this is not supported'
          is_expected.not_to include('hige')
        end
      end

      context 'with unused public method' do
        let(:source) do
          <<-EOS
          class A
            def hoge
            end
          end
          EOS
        end
        let(:sources) { [source] }

        it { is_expected.to include('hoge') }
      end

      context 'with used public method' do
        let(:source) do
          <<-EOS
          class A
            def hoge
            end

            def hige
              hoge
            end
          end
          EOS
        end
        let(:sources) { [source] }

        it { is_expected.not_to include('hoge') }
      end
    end

    context 'in included' do
      it 'has no unused method'
      it 'has one unused method'
    end

    context 'in extended' do
      it 'has no unused method'
      it 'has one unused method'
    end

    context '#formatted_unused_methods' do
      it 'has no unused method'
      it 'has one unused method'
    end
  end
end
