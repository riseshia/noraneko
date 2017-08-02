# frozen_string_literal: true

module Noraneko
  class NView
    attr_accessor :called_views
    attr_reader :filepath

    def initialize(filepath, type = :normal)
      @filepath = filepath
      @rel_path = filepath.split('/views/').drop(1).join('').split('.').first
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

    def name
      @rel_path
    end
  end
end
