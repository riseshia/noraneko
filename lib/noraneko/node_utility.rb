# frozen_string_literal: true

module Noraneko
  module NodeUtility
    def extract_consts(const_node, consts = [])
      next_const_node, const_sym = const_node.children
      consts.unshift(const_sym)
      if next_const_node
        extract_consts(next_const_node, consts)
      else
        consts
      end
    end
  end
end
