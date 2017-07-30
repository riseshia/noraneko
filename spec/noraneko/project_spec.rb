# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Noraneko::Project do
  subject(:unused_names) { project.all_unuseds.map(&:name) }
  let(:registry) { Noraneko::Registry.new }
  let(:processor) { Noraneko::Processor.init_with(registry: registry) }
  let(:project) { described_class.new(registry) }

  before { processor.process(Parser::CurrentRuby.parse(source)) }

  describe '#all_unuseds' do
    context 'with method' do
      let(:source) do
        <<-EOS
        class A
          def unused_public
            used_private
            used_private_with_keyword
            used_public
          end

          def used_public
          end

          def unused_private_with_keyword; end
          def used_private_with_keyword; end
          private :unused_private_with_keyword
          private :used_private_with_keyword

          private
          def unused_private; end
          def used_private; end
        end
        EOS
      end

      it { expect(unused_names).to include(:unused_private) }
      it { expect(unused_names).not_to include(:used_private) }
      it { expect(unused_names).to include(:unused_private_with_keyword) }
      it { expect(unused_names).not_to include(:used_private_with_keyword) }
      it { expect(unused_names).to include(:unused_public) }
      it { expect(unused_names).not_to include(:used_public) }
    end

    context 'with include' do
      let(:source) do
        <<-EOS
        module UsedMod
          def hoge; end
        end

        module UnusedMod
          def hige; end
        end

        class A
          include UsedMod
          include UnusedMod
          def hello
            hoge
          end
        end
        EOS
      end

      it { expect(unused_names).not_to include('UsedMod') }
      it { expect(unused_names).to include('UnusedMod') }
    end

    context 'with extend' do
      let(:source) do
        <<-EOS
        module UsedMod
          def hoge; end
        end
        module UnusedMod
          def hige; end
        end

        class A
          extend UsedMod, UnusedMod
          def hello
            self.class.hoge
          end
        end
        EOS
      end

      it { expect(unused_names).not_to include('UsedMod') }
      it { expect(unused_names).to include('UnusedMod') }
    end

    context 'with controller' do
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

      it { expect(unused_names).not_to include(:index) }
      it { expect(unused_names).not_to include(:auth) }
    end
  end
end
