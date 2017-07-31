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

    def extract_syms(nodes)
      nodes.map { |n| n.children.last }
    end

    def convert_to_hash(node)
      raise 'This is not hash expression' unless node.type == :hash
      node.children.each_with_object({}) do |pair, hash|
        key, value = pair.children
        if convertable?(key) && convertable?(value)
          hash[convert!(key)] = convert!(value)
        end
      end
    end

    private

    def convertable?(node)
      %i[sym str].include?(node.type) ? true : false
    end

    def convert!(node)
      node.children.last
    end
  end
end
