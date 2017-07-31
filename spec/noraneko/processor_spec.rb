# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::Processor do
  subject(:processor) do
    described_class.init_with(registry: registry, filepath: filepath)
  end
  let(:filepath) { nil }
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

    context 'with module_function' do
      let(:source) do
        <<-EOS
          class Hoge
            def mf1; end
            def mf2; end

            module_function :mf1, :mf2

            module_function
            def mf3; end
          end
        EOS
      end

      let(:nconst) { registry.find('Hoge') }

      it 'Hige::Hoge has class methods' do
        expect(nconst.find_method(:mf1).class_method?).to be(true)
        expect(nconst.find_method(:mf2).class_method?).to be(true)
        expect(nconst.find_method(:mf3).class_method?).to be(true)
      end
    end
  end

  describe 'instance method parse' do
    context 'global method' do
      let(:source) do
        <<-EOS
          def hoge; end
          alias_method :aliased_hoge, :hoge
        EOS
      end
      let(:nconst) { registry.find('') }

      it 'registers hoge method' do
        nmethod = nconst.find_method(:hoge)
        expect(nmethod.in_public?).to be(true)
        expect(nmethod.instance_method?).to be(true)
      end

      it 'registers aliasesd method' do
        nmethod = nconst.find_method(:aliased_hoge)
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
            def private_imethod2; end
            private :private_imethod1, :private_imethod2

            private
            def private_imethod3; end
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

      it 'registers Hoge#private_imethod3 on local private scope' do
        nmethod = nconst.find_method(:private_imethod3)
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
            include variable
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

      it 'does not parse include with variable' do
        nconst = registry.find('Hege')
        expect(nconst.included_module_names).not_to include %w[variable]
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
            extend variable
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

      it 'does not parse extend with variable' do
        nconst = registry.find('Hage')
        expect(nconst.extended_module_names).not_to include %w[variable]
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

    context 'explicit send' do
      let(:source) do
        <<-EOS
        class Hoge
          def hello
            send(:bye)
            send("goodbye")
          end
          def bye; end
          def goodbye; end
        end
        EOS
      end

      it 'Hoge#hello call bye, goodbye' do
        nconst = registry.find('Hoge')
        hello = nconst.find_method(:hello)
        expect(hello.called?(:bye)).to eq(true)
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

  describe 'parse render call in controller' do
    let(:source) do
      <<-EOS
      class HogeController
        layout 'hoge'
        layout :hige

        def index; end
        def edit
          render :edit_via_sym
          render action: :edit_in_action
          render "edit_via_string"
          render "edit_with_extension.html.erb"
          render action: "edit_in_action_via_string"
          render action: "edit_in_action_with_extension.html.erb"
          render "books/edit_with_path"
          render "books/edit_with_path_extension.html.erb"
          render template: "books/edit_in_tem_with_path"
          render template: "books/edit_in_tem_with_path_extention.html.erb"
        end
      end
      EOS
    end

    let(:nconst) { registry.find('HogeController') }
    let(:filepath) { 'app/controllers/hoge_controller.rb' }

    it { expect(nconst.used_view?('layouts/hoge')).to be(true) }
    it { expect(nconst.used_view?('layouts/hige')).to be(true) }
    it { expect(nconst.used_view?('hoge/index')).to be(true) }
    it { expect(nconst.used_view?('hoge/edit_via_sym')).to be(true) }
    it { expect(nconst.used_view?('hoge/edit_in_action')).to be(true) }
    it { expect(nconst.used_view?('hoge/edit_via_string')).to be(true) }
    it { expect(nconst.used_view?('hoge/edit_with_extension')).to be(true) }
    it { expect(nconst.used_view?('hoge/edit_in_action_via_string')).to be(true) }
    it { expect(nconst.used_view?('hoge/edit_in_action_with_extension')).to be(true) }
    it { expect(nconst.used_view?('books/edit_with_path')).to be(true) }
    it { expect(nconst.used_view?('books/edit_with_path_extension')).to be(true) }
    it { expect(nconst.used_view?('books/edit_in_tem_with_path')).to be(true) }
    it { expect(nconst.used_view?('books/edit_in_tem_with_path_extention')).to be(true) }
  end
end
