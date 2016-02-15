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
      # @overload compare(type, options = {}, &block)
      #   @param type [Class] The object type to compare. Objects of this class
      #     or subclasses of this class will be compared using the block.
      #   @param options [Hash] Additional options for the comparison.
      #
      #   @yield Defines the comparison.
      #   @yieldparam u The first compared object.
      #   @yieldparam v The second compared object.
      #   @yieldparam options [Hash] A hash of additional options.
      #   @yieldreturn The return value of the comparison.
      #
      # @overload compare(first_type, second_type, options = {}, &block)
      #   @param first_type [Class] The first object type to compare. One of the
      #     compared objects must be of this type, and the other object must be
      #     of the second type regardless of order unless the :reversible option
      #     is set to false
      #   @param second_type [Class] The second object type to compare.
      #   @param options [Hash] Additional options for the comparison.
      #
      #   @option options [Boolean] :reversible If true, the comparison will
      #     match both [first_type, second_type] and [second_type, first_type].
      #     Otherwise, only [first_type, second_type] will match. Defaults to
      #     true.
      #
      #   @yield Defines the comparison.
      #   @yieldparam u The first compared object.
      #   @yieldparam v The second compared object.
      #   @yieldparam options [Hash] A hash of additional options.
      #   @yieldreturn The return value of the comparison.
      #
      # @overload compare(type, method_name, options = {})
      #   @param type [Class] The object type to compare. Objects of this class
      #     or subclasses of this class will be compared using the specified
      #     method.
      #   @param method_name [String, Symbol] The name of the method to compare
      #     objects with.
      #   @param options [Hash] Additional options for the comparison.
      #
      #   @raise [ArgumentError] If the method name is not a string or symbol,
      #     or if the method name is a string or symbol but is blank.
      #
      # @overload compare(first_type, second_type, method_name, options = {})
      #   @param first_type [Class] The first object type to compare. One of the
      #     compared objects must be of this type, and the other object must be
      #     of the second type regardless of order unless the :reversible option
      #     is set to false
      #   @param second_type [Class] The second object type to compare.
      #   @param method_name [String, Symbol] The name of the method to compare
      #     objects with.
      #   @param options [Hash] Additional options for the comparison.
      #
      #   @option options [Boolean] :reversible If true, the comparison will
      #     match both [first_type, second_type] and [second_type, first_type].
      #     Otherwise, only [first_type, second_type] will match. Defaults to
      #     true.
      #
      #   @raise [ArgumentError] If the method name is not a string or symbol,
      #     or if the method name is a string or symbol but is blank.
      def compare *args, &block
        if args.count > 4
          raise ArgumentError, "wrong number of arguments (given #{args.count}, expected 4)"
        end # if

        first_type = args.shift
        options    = {
          :reversible => true
        } # end options
        options.update(args.pop) if args.last.is_a?(Hash)

        case args.count
        when 0
          raise ArgumentError, 'must provide a method name or block' unless block_given?

          second_type = first_type
          comparison  = block
        when 1
          arg = args.first

          if valid_predicate?(arg)
            raise ArgumentError, 'must provide a method name or block' unless block_given?

            second_type = arg
            comparison  = block
          else
            validate_method_name arg

            second_type = first_type
            comparison  = arg
          end # if-else
        when 2
          validate_method_name args.last

          second_type = args.first
          comparison  = args.last
        end

        comparisons.unshift({
          :match_first  => build_predicate_matcher(first_type),
          :match_second => build_predicate_matcher(second_type),
          :comparison   => comparison,
          :options      => options
        }) # end object
      end # method compare

      protected

      # @api private
      def comparison_for u, v
        comparisons.each do |hsh|
          if hsh[:match_first] === u && hsh[:match_second] === v
            return hsh[:comparison], false
          elsif hsh[:options][:reversible] && hsh[:match_first] === v && hsh[:match_second] === u
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
