# lib/rspec/sleeping_king_studios/examples/shared_example_group.rb

require 'rspec/sleeping_king_studios/examples'

module RSpec::SleepingKingStudios::Examples
  module SharedExampleGroup
    # Aliases a defined shared example group, allowing it to be accessed using
    # a new name. The example group must be defined in the current context
    # using `shared_examples`. The aliases must be defined before including the
    # module into an example group, or they will not be available in the
    # example group.
    #
    # @param [String] new_name The new name to alias the shared example group
    #   as.
    # @param [String] old_name The name under which the shared example group is
    #   currently defined.
    def alias_shared_examples new_name, old_name
      proc = shared_example_groups[self][old_name]

      self.shared_examples new_name, &proc
    end # method alias_shared_examples

    # @api private
    def included other
      merge_shared_example_groups other
    end # method included

    # @overload shared_examples(name, &block)
    #   @param [String] name Identifer to use when looking up this shared group.
    #   @param block Used to create the shared example group definition.
    # @overload shared_examples(name, metadata, &block)
    #   @param [String] name Identifer to use when looking up this shared group.
    #   @param metadata [Array<Symbol>, Hash] Metadata to attach to this group;
    #     any example group with matching metadata will automatically include
    #     this shared example group.
    #   @param block Used to create the shared example group definition.
    #
    # Defines a shared example group within the context of the current module.
    # Unlike a top-level example group defined using RSpec#shared_examples,
    # these examples are not globally available, and must be mixed into an
    # example group by including the module. The shared examples must be
    # defined before including the module, or they will not be available in the
    # example group.
    def shared_examples name, *metadata_args, &block
      RSpec.world.shared_example_group_registry.add(self, name, *metadata_args, &block)
    end # method shared_examples

    private

    # @api private
    def merge_shared_example_groups other
      shared_example_groups[self].each do |name, proc|
        RSpec.world.shared_example_group_registry.add(other, name, &proc)
      end # each
    end # method merge_shared_example_groups

    # @api private
    def shared_example_groups
      RSpec.world.shared_example_group_registry.send :shared_example_groups
    end # method shared_example_groups
  end # module
end # module
