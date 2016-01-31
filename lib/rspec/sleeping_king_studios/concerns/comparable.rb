# lib/rspec/sleeping_king_studios/concerns/comparable.rb

require 'rspec/sleeping_king_studios/concerns'

module RSpec::SleepingKingStudios::Concerns
  # Method and namespace for building and using customised comparators.
  module Comparable
    class UnimplementedComparisonError < StandardError
      def initialize u, v
        super "no comparison is defined to compare #{u.inspect} with #{v.inspect}"
      end # method initialize
    end # end class
  end # module
end # module
