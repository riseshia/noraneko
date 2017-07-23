require 'spec_helper'

RSpec.describe Noraneko::Project do
  context '#unused_methods' do
    subject { project.unused_methods }
    let(:project) { Project.new }
    let(:descriptions) { sources.map { |s| Analyzer.new.execute(s) } }

    before do
      expect(project).to receive(:descriptions).and_return(descriptions)
    end

    context 'in class' do
      let(:source_a) do
        <<-EOS
        class A
          def hoge
          end
        end
        EOS
      end

      context 'with no unused method' do
        let(:source_b) do
          <<-EOS
          class B
            def hoge
          end
          EOS
        end
        # it { is_expected.to be_empty }
      end

      context 'with 1 unused method' do
      end
    end

    context 'in included' do
      it 'has no unused method'
      it 'has one unused method'
    end

    context 'in extended' do
      it 'has no unused method'
      it 'has one unused method'
    end

    context '#formatted_unused_methods' do
      it 'has no unused method'
      it 'has one unused method'
    end
  end
end
