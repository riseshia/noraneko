# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::Analyzer do
  let(:description) { Analyzer.new.execute(source) }
end
