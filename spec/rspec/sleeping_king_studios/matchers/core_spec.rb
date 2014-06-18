# spec/rspec/sleeping_king_studios/matchers/core_spec.rb

require 'rspec/sleeping_king_studios/spec_helper'

require 'rspec/sleeping_king_studios/matchers/core'

describe RSpec::SleepingKingStudios::Matchers::Core do
  def self.matchers
    Dir[File.join File.dirname(__FILE__), 'core', '*_spec.rb'].map do |file|
      File.split(file).last.gsub(/_spec.rb/,'')
    end # end each
  end # class method matchers
  
  let(:matchers)      { self.class.matchers }
  let(:example_group) { self }
  
  matchers.each do |matcher|
    context do
      it { expect(example_group).to respond_to matcher }
    end # context
  end # each
end # describe
