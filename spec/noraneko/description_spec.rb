# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::Description do
  let(:description) { Noraneko::Analyzer.new.execute(source) }

  context '#build_context' do
    context 'with simple class which has no method' do
      let(:source) do
        <<-EOS
        class SimpleClass
        end
        EOS
      end

      it 'is a class description' do
        expect(description.type).to eq(:class)
      end

      it 'has name as "SimpleClass"' do
        expect(description.name).to eq('SimpleClass')
      end

      it 'has no public instance method' do
        expect(description.defined_public_methods).to be_empty
      end

      it 'has no private instance method' do
        expect(description.defined_private_methods).to be_empty
      end

      it 'has no expended module' do
        expect(description.extended_modules).to be_empty
      end

      it 'has no included module' do
        expect(description.included_modules).to be_empty
      end
    end

    context 'with complex class' do
      let(:source) do
        <<-EOS
        class ComplexClass
          include OddEye
          extend Nekomimi

          def hoge
          end

          def noge;end

          def self.coge
          end

          class << self
           def koge
           end
          end

          def moge
          end
          private :moge

          private

          def loge
          end
        end
        EOS
      end

      it 'is a class description' do
        expect(description.type).to eq(:class)
      end

      it 'has name as "ComplexClass"' do
        expect(description.name).to eq('ComplexClass')
      end

      it 'has 4 public instance method' do
        expect(description.defined_public_methods).to \
          eq(%w[coge hoge koge noge])
      end

      it 'has two private instance method' do
        expect(description.defined_private_methods).to \
          eq(%w[loge moge])
      end

      it 'has one expended module' do
        expect(description.extended_modules).to eq(%w[Nekomimi])
      end

      it 'has one included module' do
        expect(description.included_modules).to eq(%w[OddEye])
      end
    end

    context 'with module' do
      let(:source) do
        <<-EOS
        module ComplexModule
          include OddEye
          extend Nekomimi

          def hoge
          end

          module_function

          def hige
          end
        end
        EOS
      end

      it 'is a module description' do
        expect(description.type).to eq(:module)
      end

      it 'has name as "ComplexModule"' do
        expect(description.name).to eq('ComplexModule')
      end

      it 'has one public instance method' do
        expect(description.defined_public_methods).to \
          eq(%w[hige hoge])
      end

      it 'has one private instance method' do
        expect(description.defined_private_methods).to be_empty
      end

      it 'has one expended module' do
        expect(description.extended_modules).to eq(%w[Nekomimi])
      end

      it 'has one included module' do
        expect(description.included_modules).to eq(%w[OddEye])
      end
    end
  end

  context '#using?' do
    let(:source) do
      <<-EOS
      class SimpleClass
        def used_public
          external_method
          used_private
        end

        def hige
          used_public + 1
        end

        private

        def used_private
        end

        def unused_private
        end
      end
      EOS
    end

    context 'with used method' do
      %w[external_method used_public used_private].each do |method_name|
        it "#{method_name} is used" do
          expect(description.using?(method_name)).to eq(true)
        end
      end
    end

    context 'with unused method' do
      %w[unused_public unused_private].each do |method_name|
        it "#{method_name} is not used" do
          expect(description.using?(method_name)).to eq(false)
        end
      end
    end
  end
end
