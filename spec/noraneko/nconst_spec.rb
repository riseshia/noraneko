# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::NConst do
  describe '#loc' do
    let(:nconst) { described_class.new('Hoge', 'lib/test/hoge.rb', 3) }

    it 'returns currect loc' do
      expect(nconst.loc).to eq('lib/test/hoge.rb:3')
    end
  end

  describe '#controller?' do
    let(:nconst) { described_class.new(module_name, 'lib/test/hoge.rb', 3) }

    context 'with nconst postfixed "Controller"' do
      let(:module_name) { 'Hoge' }
      it { expect(nconst.controller?).to be(false) }
    end

    context 'with nconst postfixed "Controller"' do
      let(:module_name) { 'HogeController' }
      it { expect(nconst.controller?).to be(true) }
    end
  end
end
