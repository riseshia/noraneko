# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::Processor do
  subject(:processor) { described_class.init_with(registry: registry) }
  let(:registry) { Noraneko::Registry.new }
  let(:ast) { Parser::CurrentRuby.parse(source) }
  before { processor.process(ast) }

  context 'parse class' do
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

    context 'with nested in module' do
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
  end

  context 'parse module' do
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
end
