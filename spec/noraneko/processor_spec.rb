# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::Processor do
  subject(:processor) { described_class.init_with(registry: registry) }
  let(:registry) { Noraneko::Registry.new }
  let(:ast) { Parser::CurrentRuby.parse(source) }
  before { processor.process(ast) }

  describe 'class parse' do
    context 'with simple one' do
      let(:source) { 'class Hoge;end' }

      it 'registers Hoge class' do
        expect(registry.find('Hoge')).not_to be_nil
      end
    end

    context 'with nested one' do
      let(:source) { 'class Hige::Hoge::Hage;end' }

      it 'registers Hige::Hoge::Hage class' do
        expect(registry.find('Hige::Hoge::Hage')).not_to be_nil
      end
    end

    context 'with nested class in class' do
      let(:source) do
        <<-EOS
        class Hige
          class Hoge;end
        end
        EOS
      end

      it 'registers Hige::Hoge and Hige' do
        expect(registry.find('Hige')).not_to be_nil
        expect(registry.find('Hige::Hoge')).not_to be_nil
      end
    end
  end

  describe 'module parse' do
    context 'with nested class in module' do
      let(:source) do
        <<-EOS
        module Hige
          class Hoge;end
        end
        EOS
      end

      it 'registers Hige::Hoge and Hige' do
        expect(registry.find('Hige')).not_to be_nil
        expect(registry.find('Hige::Hoge')).not_to be_nil
      end
    end

    context 'with simple one' do
      let(:source) { 'module Hoge;end' }

      it 'registers Hoge module' do
        expect(registry.find('Hoge')).not_to be_nil
      end
    end

    context 'with nested one' do
      let(:source) { 'module Hige::Hoge;end' }

      it 'registers Hige::Hoge module' do
        expect(registry.find('Hige::Hoge')).not_to be_nil
      end
    end
  end

  describe 'instance method parse' do
    context 'simple method' do
      let(:source) { 'def hoge; end' }
      let(:nconst) { registry.find('') }

      it 'registers hoge method' do
        nmethod = nconst.find_method(:hoge)
        expect(nmethod.in_public?).to be(true)
        expect(nmethod.instance_method?).to be(true)
      end
    end

    context 'when in class' do
      let(:source) do
        <<-EOS
          class Hoge
            def public_imethod; end

            def private_imethod1; end
            private :private_imethod1

            private
            def private_imethod2; end
          end
        EOS
      end

      let(:nconst) { registry.find('Hoge') }

      it 'registers Hoge#public_imethod' do
        nmethod = nconst.find_method(:public_imethod)
        expect(nmethod.in_public?).to be(true)
        expect(nmethod.instance_method?).to be(true)
      end

      it 'registers Hoge#private_imethod1 on local private scope' do
        nmethod = nconst.find_method(:private_imethod1)
        expect(nmethod.in_private?).to be(true)
        expect(nmethod.instance_method?).to be(true)
      end

      it 'registers Hoge#private_imethod2 on local private scope' do
        nmethod = nconst.find_method(:private_imethod2)
        expect(nmethod.in_private?).to be(true)
        expect(nmethod.instance_method?).to be(true)
      end
    end
  end

  describe 'class method parse' do
    let(:source) do
      <<-EOS
        class Hoge
          def self.cls_method; end

          class << self
            def self_public_cmethod; end

            def self_private_cmethod1; end
            private :self_private_cmethod1

            private
            def self_private_cmethod2; end
          end
        end
      EOS
    end

    let(:nconst) { registry.find('Hoge') }

    it 'registers Hoge.cls_method on public scope' do
      nmethod = nconst.find_method(:cls_method)
      expect(nmethod.in_public?).to be(true)
      expect(nmethod.class_method?).to be(true)
    end

    it 'registers Hoge.self_cls_method on public scope' do
      nmethod = nconst.find_method(:self_public_cmethod)
      expect(nmethod.in_public?).to be(true)
      expect(nmethod.class_method?).to be(true)
    end

    it 'registers Hoge.self_private_cmethod1 on private scope' do
      nmethod = nconst.find_method(:self_private_cmethod1)
      expect(nmethod.in_private?).to be(true)
      expect(nmethod.class_method?).to be(true)
    end

    it 'registers Hoge.self_private_cmethod1 on private scope' do
      nmethod = nconst.find_method(:self_private_cmethod2)
      expect(nmethod.in_private?).to be(true)
      expect(nmethod.class_method?).to be(true)
    end
  end

  describe 'include, extend parse' do
    context 'with include keyword' do
      let(:source) do
        <<-EOS
          module A; end
          module B; end
          module C; module D; end; end

          class Hoge; include A; end

          class Hige; include B, C; end

          class Hage
            include B
            include C
          end

          class Hege; include C::D; end
        EOS
      end

      it 'parses include with one param' do
        nconst = registry.find('Hoge')
        expect(nconst.included_module_names).to eq %w[A]
      end

      it 'parses include with 2 params' do
        nconst = registry.find('Hige')
        expect(nconst.included_module_names).to eq %w[B C]
      end

      it 'parses multy include' do
        nconst = registry.find('Hage')
        expect(nconst.included_module_names).to eq %w[B C]
      end

      it 'parses include with qualified param' do
        nconst = registry.find('Hege')
        expect(nconst.included_module_names).to eq %w[C::D]
      end
    end

    context 'with extend keyword' do
      let(:source) do
        <<-EOS
          module A; end
          module B; end
          module C; module D; end; end

          class Hoge; extend A; end

          class Hige; extend B, C; end

          class Hage
            extend B
            extend C
          end

          class Hege; extend C::D; end
        EOS
      end

      it 'parses extend with one param' do
        nconst = registry.find('Hoge')
        expect(nconst.extended_module_names).to eq %w[A]
      end

      it 'parses extend with 2 params' do
        nconst = registry.find('Hige')
        expect(nconst.extended_module_names).to eq %w[B C]
      end

      it 'parses multy extend' do
        nconst = registry.find('Hage')
        expect(nconst.extended_module_names).to eq %w[B C]
      end

      it 'parses extend with qualified param' do
        nconst = registry.find('Hege')
        expect(nconst.extended_module_names).to eq %w[C::D]
      end
    end
  end

  describe 'parse called method' do
    context 'simple call' do
      let(:source) do
        <<-EOS
        class Hoge
          def hello
            bye
          end
          def bye; end
        end
        EOS
      end

      it 'Hoge#hello call bye' do
        nconst = registry.find('Hoge')
        hello = nconst.find_method(:hello)
        expect(hello.called?(:bye)).to eq(true)
      end
    end

    context 'call chain' do
      let(:source) do
        <<-EOS
        class Hoge
          def hello
            bye.see_you_later
          end
          def bye; end
          def see_you_later; end
        end
        EOS
      end

      it 'Hoge#hello call bye, see_you_later' do
        nconst = registry.find('Hoge')
        hello = nconst.find_method(:hello)
        expect(hello.called?(:bye)).to eq(true)
        expect(hello.called?(:see_you_later)).to eq(true)
      end
    end

    context 'passed method symbol' do
      let(:source) do
        <<-EOS
        class Hoge
          def hello
            list.map(&:pass_sym)
            list.map { |el| block_call(el) }
          end
          def pass_sym; end
          def block_call; end
        end
        EOS
      end

      it 'Hoge#hello call pass_sym, block_call' do
        nconst = registry.find('Hoge')
        hello = nconst.find_method(:hello)
        expect(hello.called?(:pass_sym)).to eq(true)
        expect(hello.called?(:block_call)).to eq(true)
      end
    end
  end

  describe 'parse DSL which registers callback' do
    let(:source) do
      <<-EOS
      class HogeController
        before_action :auth, only: :index
        def index; end

        private
        def auth; end
      end
      EOS
    end

    it 'has 1 DSL' do
      nconst = registry.find('HogeController')
      expect(nconst.registered_callbacks).to include(:auth)
    end
  end
end
