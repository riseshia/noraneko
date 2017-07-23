require 'spec_helper'

module Noraneko
  RSpec.describe Analyzer do
    let(:description) { Analyzer.new.execute(source) }

    context 'with simple class which has no method' do
      let(:source) do
        <<-EOC
        class SimpleClass
        end
        EOC
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
        <<-EOC
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
        EOC
      end

      it 'is a class description' do
        expect(description.type).to eq(:class)
      end

      it 'has name as "ComplexClass"' do
        expect(description.name).to eq('ComplexClass')
      end

      it 'has two public instance method' do
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
  end
end
