# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::Project do
  let(:registry) { Noraneko::Registry.new }
  let(:processor) { Noraneko::Processor.init_with(registry: registry) }
  let(:project) { described_class.new(registry) }

  before do
    sources.each do |source|
      processor.process(
        Parser::CurrentRuby.parse(source)
      )
    end
  end

  context '#unused_methods' do
    subject(:unused_method_names) { project.unused_methods.map(&:name) }

    context 'in class' do
      context 'with not used private method' do
        let(:source) do
          <<-EOS
          class A
            private
            def hoge; end
          end
          EOS
        end
        let(:sources) { [source] }

        it { is_expected.to include(:hoge) }
      end

      context 'with used private method' do
        let(:source) do
          <<-EOS
          class A
            def hoge
              hige
            end
            private
            def hige; end
          end
          EOS
        end
        let(:sources) { [source] }

        it { is_expected.not_to include(:hige) }
      end

      context 'with used private method with private keyword' do
        let(:source) do
          <<-EOS
          class A
            def hoge
              hige
            end
            def hige; end
            private :hige
          end
          EOS
        end
        let(:sources) { [source] }

        it do
          is_expected.not_to include(:hige)
        end
      end

      context 'with unused public method' do
        let(:source) do
          <<-EOS
          class A
            def hoge; end
          end
          EOS
        end
        let(:sources) { [source] }

        it { is_expected.to include(:hoge) }
      end

      context 'with used public method' do
        let(:source) do
          <<-EOS
          class A
            def hoge; end

            def hige
              hoge
            end
          end
          EOS
        end
        let(:sources) { [source] }

        it { is_expected.not_to include(:hoge) }
      end
    end
  end

  context '#unused_modules' do
    subject(:unused_module_names) { project.unused_modules.map(&:name) }

    context 'with include' do
      context 'with used method' do
        let(:source) do
          <<-EOS
          module Mod
            def hoge; end
          end

          class A
            include Mod
            def hello
              hoge
            end
          end
          EOS
        end
        let(:sources) { [source] }

        it { is_expected.not_to include('Mod') }
      end

      context 'with unused method' do
        let(:source) do
          <<-EOS
          module Mod
            def hoge; end
          end

          class A
            include Mod
            def hello; end
          end
          EOS
        end
        let(:sources) { [source] }

        it { is_expected.to include('Mod') }
      end
    end

    context 'with extend' do
      context 'with used method' do
        let(:source) do
          <<-EOS
          module Mod
            def hoge; end
          end

          class A
            extend Mod
            def hello
              self.class.hoge
            end
          end
          EOS
        end
        let(:sources) { [source] }

        it { is_expected.not_to include('Mod') }
      end

      context 'with unused method' do
        let(:source) do
          <<-EOS
          module Mod
            def hoge; end
          end

          class A
            extend Mod
            def hello; end
          end
          EOS
        end
        let(:sources) { [source] }

        it { is_expected.to include('Mod') }
      end
    end
  end
end
