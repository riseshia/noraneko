# frozen_string_literal: true

module Noraneko
  class Registry
    def initialize
      @namespace = {}
    end

    def find(name)
      @namespace[name]
    end

    def put(nconst)
      @namespace[nconst.qualified_name] = nconst
    end

    def update_or_create(nconst)
      registed = find(nconst.qualified_name)
      if registed
        registed.merge(nconst)
      else
        put(nconst)
      end
    end
  end
end
