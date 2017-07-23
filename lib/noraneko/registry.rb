# frozen_string_literal: true

module Noraneko
  class Registry
    def initialize
      @namespace = {}
    end

    def find(name)
      @namespace[name]
    end

    def put(name, nconst)
      @namespace[name] = nconst
    end

    def update_or_create(name, nconst)
      registed = find(name)
      if registed
        registed.merge(nconst)
      else
        put(name, nconst)
      end
    end
  end
end
