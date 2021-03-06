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

    def delete(nconst)
      @namespace.delete(nconst.qualified_name)
    end

    def to_a
      @namespace.values
    end
  end
end
