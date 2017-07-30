# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::CLI do
  subject { described_class.new.run }

  describe 'run successfully' do
    context 'has no unused method' do
      before do
        expect_any_instance_of(Noraneko::Runner).to \
          receive(:run).and_return([])
      end

      it { is_expected.to eq(0) }
    end

    context 'has unused method' do
      let(:nconst) { Noraneko::NConst.new('Hoge', 'lib/hoge.rb', 3) }
      before do
        expect_any_instance_of(Noraneko::Runner).to \
          receive(:run).and_return([nconst])
      end

      it { is_expected.to eq(1) }
    end
  end

  describe 'has error' do
    before do
      expect_any_instance_of(Noraneko::Runner).to \
        receive(:run).and_raise(StandardError)
    end

    it { is_expected.to eq(2) }
  end
end
