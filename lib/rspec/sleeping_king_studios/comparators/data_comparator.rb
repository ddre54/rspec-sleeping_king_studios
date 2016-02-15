# lib/rspec/sleeping_king_studios/comparators/data_comparator.rb

require 'rspec/sleeping_king_studios/comparators/comparator'

module RSpec::SleepingKingStudios::Comparators
  # Class for comparing recursive data structures.
  class DataComparator < Comparator
    compare Object do |*| false; end

    [FalseClass, Float, Integer, NilClass, String, Symbol, TrueClass].each do |type|
      compare type, type do |u, v, o|
        u == v
      end # compare
    end # each

    compare Array, :compare_arrays

    compare Hash, :compare_hashes

    # (see RSpec::SleepingKingStudios::Comparators::Comparator#compare)
    def compare u, v, options = {}
      options_with_defaults = {
        :indifferent_access => false,
        :ordered            => true
      }.merge options

      super u, v, options_with_defaults
    end # method compare

    private

    # @api private
    def compare_arrays u, v, options
      return false unless u.count == v.count

      if options[:ordered]
        compare_lists u, v, options
      else
        compare_sets u, v, options
      end # if-else
    end # method compare_arrays

    # @api private
    def compare_hash_keys u, v, options
      if options[:indifferent_access]
        u.keys.map(&:to_s) == v.keys.map(&:to_s)
      else
        u.keys == v.keys
      end # if-else
    end # method compare_hash_keys

    # @api private
    def compare_hash_values u, v, options
      u.each do |key, value|
        if options[:indifferent_access]
          other = if v.key?(key)
            v[key]
          elsif v.key?(key.to_s)
            v[key.to_s]
          elsif v.key?(key.intern)
            v[key.intern]
          else
            matching_key = v.keys.find { |obj| obj.to_s == key.to_s }

            v[matching_key]
          end # if-else
        else
          other = v[key]
        end # if-else

        return false unless run_comparison(value, other, options)
      end # each

      true
    end # method compare_hash_values

    # @api private
    def compare_hashes u, v, options
      compare_hash_keys(u, v, options) && compare_hash_values(u, v, options)
    end # method compare_hashes

    # @api private
    def compare_lists u, v, options
      u.each.with_index do |value, index|
        other = v[index]

        return false unless run_comparison(value, other, options)
      end # each

      true
    end # method compare_lists

    # @api private
    def compare_sets u, v, options
      first, second = u.dup, v.dup

      first.each do |first_item|
        matched = false

        # Iterating through the candidates array in reverse order, so when we
        # remove an item it does not change the index of later items.
        (second.count - 1).downto(0) do |index|
          second_item = second[index]

          if matched = run_comparison(first_item, second_item, options)
            # Splice second_item from array.
            second[index..index] = []

            break
          end # if
        end # downto

        return false unless matched
      end # each

      true
    end # method compare_sets
  end # class
end # class
