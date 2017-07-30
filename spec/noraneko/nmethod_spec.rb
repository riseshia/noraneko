# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::NMethod do
  describe '#loc' do
    let(:nconst) { Noraneko::NConst.new('Hoge', 'lib/hoge.rb', 3) }
    let(:nmethod) { described_class.instance_method(nconst, :hello, 3) }

    it 'returns currect loc' do
      expect(nmethod.loc).to eq('lib/hoge.rb:3')
    end
  end
end
