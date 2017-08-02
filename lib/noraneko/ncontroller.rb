module Noraneko
  class NController < Noraneko::NConst
    def initialize(qualified_name, path, line)
      super
      @called_views = []
    end

    def controller?
      true
    end

    def used?(target_method)
      return true if action_of_this?(target_method)
      super
    end

    def called_view(view_name)
      @called_views << view_name
    end

    def used_view?(target_view_name)
      explicit = @called_views.any? { |name| name == target_view_name }
      return true if explicit
      return false unless target_view_name.start_with?(rel_path_from_controller)
      tokens = target_view_name.split('/')
      return false if tokens.size < 2
      method_name = tokens.last.to_sym
      all_public_methods.any? { |m| m.name == method_name }
    end

    def rel_path_from_controller
      @path
        .split('/controllers/').drop(1).join('')
        .split('_controller.rb').first + '/'
    end

    private

    def action_of_this?(target_method)
      target_method.in?(self) && target_method.in_public?
    end
  end
end
