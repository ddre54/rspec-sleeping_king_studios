# lib/rspec/sleeping_king_studios/concerns/comparable/comparator.rb

require 'rspec/sleeping_king_studios/concerns/comparable'

module RSpec::SleepingKingStudios::Concerns::Comparable
  # Base class for defining custom comparators.
  class Comparator
    class << self
      # Defines a comparison that can be used by comparator instances of this
      # class or subclassses of this class. The comparisons are checked in
      # first-in, last-out order, so comparisons that are defined later will
      # override earlier comparisons. If two or more comparisons match an
      # object, the comparison that was defined last on the current subclass
      # will be evaluated.
      #
      # @see #compare
      #
      # @overload compare(type, &block)
      #   @param type [Class] The object type to compare. Objects of this class
      #     or subclasses of this class will be compared using the block.
      #
      #   @yield Defines the comparison.
      #   @yieldparam u The first compared object.
      #   @yieldparam v The second compared object.
      #   @yieldparam options [Hash] A hash of additional options.
      #   @yieldreturn The return value of the comparison.
      #
      # @overload compare(first_type, second_type, &block)
      #   @param first_type [Class] The first object type to compare. One of the
      #     compared objects must be of this type, and the other object must be
      #     of the second type regardless of order.
      #   @param second_type [Class] The second object type to compare.
      #
      #   @yield Defines the comparison.
      #   @yieldparam u The first compared object.
      #   @yieldparam v The second compared object.
      #   @yieldparam options [Hash] A hash of additional options.
      #   @yieldreturn The return value of the comparison.
      #
      # @overload compare(type, method_name)
      #   @param type [Class] The object type to compare. Objects of this class
      #     or subclasses of this class will be compared using the specified
      #     method.
      #   @param method_name [String, Symbol] The name of the method to compare
      #     objects with.
      #
      #   @raise [ArgumentError] If the method name is not a string or symbol,
      #     or if the method name is a string or symbol but is blank.
      #
      # @overload compare(first_type, second_type, method_name)
      #   @param first_type [Class] The first object type to compare. One of the
      #     compared objects must be of this type, and the other object must be
      #     of the second type regardless of order.
      #   @param second_type [Class] The second object type to compare.
      #   @param method_name [String, Symbol] The name of the method to compare
      #     objects with.
      #
      #   @raise [ArgumentError] If the method name is not a string or symbol,
      #     or if the method name is a string or symbol but is blank.
      def compare first_type, second_type_or_method_name = nil, method_name = nil, &block
        if method_name != nil
          validate_method_name method_name

          second_type = second_type_or_method_name
          comparison  = method_name
        elsif second_type_or_method_name != nil
          if valid_predicate?(second_type_or_method_name)
            if block_given?
              second_type = second_type_or_method_name
              comparison  = block
            else
              raise ArgumentError, 'must provide a method name or block'
            end # if-else
          else
            validate_method_name second_type_or_method_name

            second_type = first_type
            comparison  = second_type_or_method_name
          end # if-else
        else
          if block_given?
            second_type = first_type
            comparison  = block
          else
            raise ArgumentError, 'must provide a method name or block'
          end # if-else
        end # if-else

        comparisons.unshift({
          :match_first  => build_predicate_matcher(first_type),
          :match_second => build_predicate_matcher(second_type),
          :comparison   => comparison
        }) # end object
      end # method compare

      protected

      # @api private
      def comparison_for u, v
        comparisons.each do |hsh|
          if hsh[:match_first] === u && hsh[:match_second] === v
            return hsh[:comparison], false
          elsif hsh[:match_first] === v && hsh[:match_second] === u
            return hsh[:comparison], true
          end # if-elsif
        end # each

        superclass.comparison_for(u, v) if superclass < RSpec::SleepingKingStudios::Concerns::Comparable::Comparator
      end # method comparison_for

      private

      # @api private
      def build_predicate_matcher predicate
        case predicate
        when Class
          ->(obj) { obj.is_a?(predicate) }
        end # case
      end # method build_predicate_matcher

      # @api private
      def comparisons
        @comparisons ||= []
      end # method comparisons

      # @api private
      def valid_predicate? predicate
        predicate.is_a?(Class)
      end # method valid_predicate?

      # @api private
      def validate_method_name method_name
        case method_name
        when String
          raise ArgumentError, "method name can't be blank" if 0 == method_name.length
        when Symbol
          raise ArgumentError, "method name can't be blank" if 0 == method_name.to_s.length
        else
          raise ArgumentError, 'method name must be a string or symbol'
        end # case
      end # method validate_method_name
    end # eigenclass

    # Compares two objects based on the comparisons defined for the current
    # class and superclasses.
    #
    # @param u The first compared object.
    # @param v The second compared object.
    # @param options [Hash] A hash of additional options.
    #
    # @return The return value of the comparison.
    #
    # @raise [RSpec::SleepingKingStudios::Concerns::Comparable::UnimplementedComparisonError]
    #   If no comparison is found for objects u and v.
    #
    # @see Comparator.compare
    def compare u, v, options = {}
      comparison, reversed = comparison_for(u, v)

      u, v = v, u if reversed

      case comparison
      when String, Symbol
        send comparison, u, v, options
      when Proc
        comparison.call u, v, options
      else
        raise RSpec::SleepingKingStudios::Concerns::Comparable::UnimplementedComparisonError.new(u, v)
      end # unless
    end # method compare

    private

    # @api private
    def comparison_for u, v
      self.class.send :comparison_for, u, v
    end # method comparison_for
  end # class
end # module
