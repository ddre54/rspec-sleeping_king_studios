# lib/rspec/sleeping_king_studios/comparators.rb

require 'rspec/sleeping_king_studios'

module RSpec::SleepingKingStudios
  # Namespace for building and using customised comparators.
  module Comparators
    # Error for reporting when there is no defined comparison for a given object
    # tuple.
    class UnimplementedComparisonError < StandardError
      def initialize u, v
        super "no comparison is defined to compare #{u.inspect} with #{v.inspect}"
      end # method initialize
    end # end class
  end # module
end # module
