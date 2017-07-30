# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::ViewProcessor do
  subject(:processor) do
    described_class.new(registry: registry,
                        filepath: 'app/views/blog/index.html.erb')
  end
  let(:registry) { Noraneko::Registry.new }
  let(:view) { registry.find('blog/index') }
  before { processor.process(source) }

  describe '#process' do
    let(:source) do
      <<-EOS
      <%= render('single_quote') %>
      <%= render("double_quote") %>
      <%= render "without_bracket" %>
      <%= render "with_option", local: { a: 1 } %>
      <%= render('hoge/single_quote') %>
      EOS
    end

    it { expect(view.called?('blog/_single_quote')).to be(true) }
    it { expect(view.called?('blog/_double_quote')).to be(true) }
    it { expect(view.called?('blog/_without_bracket')).to be(true) }
    it { expect(view.called?('blog/_with_option')).to be(true) }
    it { expect(view.called?('hoge/_with_option')).to be(true) }
  end
end
