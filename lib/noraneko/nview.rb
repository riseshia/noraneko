# frozen_string_literal: true

module Noraneko
  class NView
    attr_accessor :called_views

    def initialize(filepath, type = :normal)
      @filepath = filepath
      @rel_path = filepath.split('/views/').drop(1).join('')
      @called_views = []
      @type = type
    end

    def called?(other_name)
      @called_views.include?(other_name)
    end

    def call_view(name)
      @called_views << name
    end

    def loc
      @filepath
    end

    def qualified_name
      @rel_path
    end

    def partial?
      @type == :partial
    end
  end
end