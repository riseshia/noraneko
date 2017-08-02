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
    let(:nconst) { described_class.new('Hoge', 'lib/test/hoge.rb', 3) }

    context 'with nconst postfixed "Controller"' do
      it { expect(nconst.controller?).to be(false) }
    end
  end

  describe '#register_send' do
    let(:nconst) { described_class.new('Hoge', 'lib/test/hoge.rb', 3) }

    context 'with exist method' do
      before do
        nconst.add_method(:hello, 1)
        nconst.register_send(:hello, :called)
      end
      let(:hello) { nconst.find_method(:hello) }

      it { expect(hello.called?(:called)).to be(true) }
    end

    context 'with not exist method' do
      it 'will be ignored' do
        expect {
          nconst.register_send(:not_existed, :called)
        }.not_to raise_error
      end
    end
  end
end
