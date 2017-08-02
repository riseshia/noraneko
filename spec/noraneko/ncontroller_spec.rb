# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::NController do
  describe '#default_layout' do
    let(:nconst) { described_class.new(qualified_name, 'lib/test/hoge.rb', 3) }

    context 'with HogeController' do
      let(:qualified_name) { 'HogeController' }
      it { expect(nconst.used_view?('layouts/hoge')).to be(true) }
    end

    context 'with Hige::HogeController' do
      let(:qualified_name) { 'Hige::HogeController' }
      it { expect(nconst.used_view?('layouts/hige/hoge')).to be(true) }
    end

    context 'with HigeHogeController' do
      let(:qualified_name) { 'HigeHogeController' }
      it { expect(nconst.used_view?('layouts/hige_hoge')).to be(true) }
    end
  end

  describe '#controller?' do
    let(:nconst) { described_class.new('HogeController', 'lib/test/hoge.rb', 3) }

    context 'with nconst postfixed "Controller"' do
      it { expect(nconst.controller?).to be(true) }
    end
  end

  describe '#used?' do
    let(:controller) do
      described_class.new('HogeController', 'lib/test/hoge.rb', 3)
    end
    let(:action) do
      Noraneko::NMethod.new(controller, :index, 1, :public, :instance)
    end
    let(:another_action) do
      ac = described_class.new('HigeController', 'lib/test/hige.rb', 3)
      ac.add_method(:index, 1)
    end

    before do
      controller.add_method(:index, 1)
    end

    context 'with controller action' do
      it { expect(controller.used?(action)).to be(true) }
      it { expect(controller.used?(another_action)).to be(false) }
    end
  end
end
