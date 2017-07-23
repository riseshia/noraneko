# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::CLI do
  subject(:cli) { described_class.new }

  describe 'run successfully' do
    it 'returns 0' do
      expect(cli.run).to eq(0)
    end
  end

  describe 'has error' do
    before do
      expect_any_instance_of(Noraneko::Runner).to \
        receive(:run).and_raise(StandardError)
    end

    it 'returns 2' do
      expect(cli.run).to eq(2)
    end
  end
end
