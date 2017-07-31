# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::NodeUtility do
  include described_class

  let(:ast) { Parser::CurrentRuby.parse(source) }

  describe '#extract_consts' do
    context 'with relative const' do
      let(:source) { 'A' }
      it { expect(extract_consts(ast)).to eq %i[A] }
    end

    context 'with qualified const' do
      let(:source) { 'A::B::C' }
      it { expect(extract_consts(ast)).to eq %i[A B C] }
    end
  end

  describe '#extract_syms' do
    let(:source) { 'method :a, :b, :c' }
    it { expect(extract_syms(ast.children[2..-1])).to eq %i[a b c] }
  end
end
