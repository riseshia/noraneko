# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::NConst do
  describe '#loc' do
    let(:nconst) { described_class.new('Hoge', 'lib/test/hoge.rb', 3) }

    it 'returns currect loc' do
      expect(nconst.loc).to eq('lib/test/hoge.rb:3')
    end
  end
end
