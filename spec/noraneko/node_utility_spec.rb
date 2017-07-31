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
      subject(:result) { extract_consts(ast) }
      let(:source) { 'A::B::C' }
      it { expect(result).to eq %i[A B C] }
    end
  end

  describe '#extract_syms' do
    subject(:result) { extract_syms(ast.children[2..-1]) }
    let(:source) { 'method :a, :b, :c' }
    it { expect(result).to eq %i[a b c] }
  end

  describe '#convert_to_hash' do
    subject(:hash) { convert_to_hash(ast) }
    let(:source) { '{ sym: :val, "str" => "val", hidden: value }' }
    it { expect(hash).to eq(sym: :val, 'str' => 'val') }
  end
end
