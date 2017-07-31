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
end
