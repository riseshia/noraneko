# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::ViewProcessor do
  subject(:processor) do
    described_class.new(registry: registry,
                        filepath: 'app/views/blog/index.html.erb')
  end
  let(:registry) { Noraneko::Registry.new }
  let(:view) { registry.find('blog/index.html.erb') }
  before { processor.process(source) }

  describe '#process' do
    let(:source) do
      <<-EOS
      <%= render('single_quote') %>
      <%= render("double_quote") %>
      <%= render "without_bracket" %>
      <%= render "with_option", local: { a: 1 } %>
      EOS
    end

    it { expect(view.called?('single_quote')).to be(true) }
    it { expect(view.called?('double_quote')).to be(true) }
    it { expect(view.called?('without_bracket')).to be(true) }
    it { expect(view.called?('with_option')).to be(true) }
  end
end
