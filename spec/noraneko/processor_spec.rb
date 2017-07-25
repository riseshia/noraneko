# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::Processor do
  subject(:processor) { described_class.init_with(registry: registry) }
  let(:registry) { Noraneko::Registry.new }
  let(:ast) { Parser::CurrentRuby.parse(source) }
  before { processor.process(ast) }

  context 'when parse class' do
    context 'with simple one' do
      let(:source) { 'class Hoge;end' }

      it 'registers Hoge class' do
        expect(registry.find('Hoge')).not_to be_nil
      end
    end

    context 'with nested one' do
      let(:source) { 'class Hige::Hoge::Hage;end' }

      it 'registers Hige::Hoge::Hage class' do
        expect(registry.find('Hige::Hoge::Hage')).not_to be_nil
      end
    end

    context 'with nested class in class' do
      let(:source) do
        <<-EOS
        class Hige
          class Hoge;end
        end
        EOS
      end

      it 'registers Hige::Hoge and Hige' do
        expect(registry.find('Hige')).not_to be_nil
        expect(registry.find('Hige::Hoge')).not_to be_nil
      end
    end
  end

  context 'when parse module' do
    context 'with nested class in module' do
      let(:source) do
        <<-EOS
        module Hige
          class Hoge;end
        end
        EOS
      end

      it 'registers Hige::Hoge and Hige' do
        expect(registry.find('Hige')).not_to be_nil
        expect(registry.find('Hige::Hoge')).not_to be_nil
      end
    end

    context 'with simple one' do
      let(:source) { 'module Hoge;end' }

      it 'registers Hoge module' do
        expect(registry.find('Hoge')).not_to be_nil
      end
    end

    context 'with nested one' do
      let(:source) { 'module Hige::Hoge;end' }

      it 'registers Hige::Hoge module' do
        expect(registry.find('Hige::Hoge')).not_to be_nil
      end
    end
  end

  context 'when parse method' do
    context 'simple method' do
      let(:source) { 'def hoge; end' }
      let(:nconst) { registry.find('') }

      it 'registers hoge method' do
        expect(nconst.public_imethods.map(&:name)).to include :hoge
      end
    end

    context 'when in class' do
      let(:source) do
        <<-EOS
          class Hoge
            def public_imethod; end
            def private_imethod; end
            private :private_imethod
          end
        EOS
      end

      let(:nconst) { registry.find('Hoge') }

      it 'registers Hoge#public_imethod' do
        expect(nconst.public_imethods.map(&:name)).to include :public_imethod
      end

      it 'registers Hoge#private_imethod' do
        expect(nconst.public_imethods.map(&:name)).to include :private_imethod
      end
    end
  end
end
