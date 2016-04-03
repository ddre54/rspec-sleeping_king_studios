# lib/rspec/sleeping_king_studios/configuration.rb

require 'rspec/sleeping_king_studios'

module RSpec::SleepingKingStudios
  # Configuration options for RSpec::SleepingKingStudios.
  class Configuration
    # Configuration options for RSpec::SleepingKingStudios::Examples.
    class Examples
      # Permitted options for :handle_missing_failure_message_with.
      MISSING_FAILURE_MESSAGE_HANDLERS = %w(ignore pending exception).map(&:intern)

      # Options for matching failure messages to strings.
      STRING_FAILURE_MESSAGE_MATCH_OPTIONS = %w(exact substring).map(&:intern)

      # Gets the handler for missing failure messages when using the matcher
      # examples, and sets to :pending if unset.
      #
      # @return [Symbol] The current missing message handler.
      def handle_missing_failure_message_with
        @handle_missing_failure_message_with ||= :pending
      end # method handle_missing_failure_message_with

      # Sets the handler for missing failure messages when using the matcher
      # examples.
      #
      # @param [Symbol] value The desired handler. Must be :ignore, :pending,
      #   or :exception.
      #
      # @raise ArgumentError If the handler is not one of the recognized
      #   values.
      def handle_missing_failure_message_with= value
        unless MISSING_FAILURE_MESSAGE_HANDLERS.include?(value)
          message = "unrecognized handler value -- must be in #{MISSING_FAILURE_MESSAGE_HANDLERS.join ', '}"

          raise ArgumentError.new message
        end # unless

        @handle_missing_failure_message_with = value
      end # method handle_missing_failure_message_with=

      # Gets the option for matching failure messages to strings, and sets to
      # :substring if unset.
      #
      # @return [Symbol] The current failure message string matching option.
      def match_string_failure_message_as
        @match_string_failure_message_as ||= :substring
      end # method match_string_failure_message_as

      # Sets the option for matching failure messages to strings.
      #
      # @param [Symbol] value The desired option. Must be :exact, :substring, or
      #   :partial (alias of :substring).
      #
      # @raise ArgumentError If the handler is not one of the recognized
      #   values.
      def match_string_failure_message_as= value
        value = :substring if value == :partial

        unless STRING_FAILURE_MESSAGE_MATCH_OPTIONS.include?(value)
          message = "unrecognized value -- must be in #{STRING_FAILURE_MESSAGE_MATCH_OPTIONS.join ', '}"

          raise ArgumentError.new message
        end # unless

        @match_string_failure_message_as = value
      end # method match_string_failure_message_as=
    end # class

    # Configuration options for RSpec::SleepingKingStudios::Matchers.
    class Matchers
      # Checks whether predicates are matched "strictly", meaning that they must
      # return either true or false.
      #
      # @return [Boolean] True if predicates are strictly matched, otherwise
      #   false.
      def strict_predicate_matching
        @strict_predicate_matching ||= false
      end # method strict_predicate_matching

      # Sets whether predicates are matched "strictly", meaning that they must
      # return either true or false.
      #
      # @param [Boolean] value The desired value. Is coerced to true or false.
      def strict_predicate_matching= value
        @strict_predicate_matching = !!value
      end # method strict_predicate_matching
    end # class

    # Get or set the configuration options for
    # RSpec::SleepingKingStudios::Examples.
    def examples &block
      (@examples ||= RSpec::SleepingKingStudios::Configuration::Examples.new).tap do |config|
        if block_given?
          config.instance_eval &block
        end # if
      end # tap
    end # method examples

    # Get or set the configuration options for
    # RSpec::SleepingKingStudios::Matchers.
    def matchers &block
      (@matchers ||= RSpec::SleepingKingStudios::Configuration::Matchers.new).tap do |config|
        if block_given?
          config.instance_eval &block
        end # if
      end # tap
    end # method matchers
  end # class
end # module

class RSpec::Core::Configuration
  # Get or set the configuration options for RSpec::SleepingKingStudios.
  def sleeping_king_studios &block
    (@sleeping_king_studios ||= RSpec::SleepingKingStudios::Configuration.new).tap do |config|
      if block_given?
        config.instance_eval &block
      end # if
    end # tap
  end # method sleeping_king_studios
end # class
