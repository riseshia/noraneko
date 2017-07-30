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


  describe '#used?' do
    let(:controller) do
      described_class.new('HogeController', 'lib/test/hoge.rb', 3)
    end
    let(:action) do
      Noraneko::NMethod.new(controller, :index, 1)
    end
    let(:another_action) do
      ac = described_class.new('HigeController', 'lib/test/hige.rb', 3)
      Noraneko::NMethod.new(ac, :index, 1)
    end

    before do
      controller.add_method(action)
    end

    context 'with controller action' do
      it { expect(controller.used?(action)).to be(true) }
      it { expect(controller.used?(another_action)).to be(false) }
    end
  end
end
