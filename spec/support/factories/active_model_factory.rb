# spec/rspec/sleeping_king_studios/factories/active_model_factory.rb

require 'active_model'

FactoryGirl.define do
  factory(:active_model, :class => Class.new do
    include ActiveModel::Validations
          
    def initialize(params = nil)
      (params || {}).each do |key, value|
        self.send :"#{key}=", value
      end # each
    end # method initialize
    
    attr_accessor :foo, :bar, :baz
    
    validates_each :foo, :bar do |record, attr, value|
      record.errors.add attr, 'not to be nil' if value.nil?
    end # validates
    
    validates_each :foo do |record, attr, value|
      record.errors.add attr, 'to be 1s and 0s' if
        value.nil? || value != value.gsub(/[^01]/,'')
    end # validates

    def inspect
      "#<Model:#{self.object_id}>"
    end # method inspect
  end) do
    foo nil
    bar nil
    baz nil
  end # factory
end # define
