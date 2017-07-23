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
        expect(description.defined_public_instance_methods).to be_empty
      end

      it 'has no private instance method' do
        expect(description.defined_private_instance_methods).to be_empty
      end

      it 'has no public class method' do
        expect(description.defined_public_class_methods).to be_empty
      end

      it 'has no expended module' do
        expect(description.expanded_modules).to be_empty
      end

      it 'has no included module' do
        expect(description.included_modules).to be_empty
      end
    end
  end
end
