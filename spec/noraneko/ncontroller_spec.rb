# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::NController do
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
      Noraneko::NMethod.instance_method(controller, :index, 1)
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