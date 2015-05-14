require 'active_support/concern'

module SearchOperator
  extend ActiveSupport::Concern

  included do
    def self.operators_by_type(operator_type)
      Rails.configuration.custom.search_operators.select{|o| o[:operator_type] == operator_type}
    end

    def self.comparison_operators
      operators_by_type('comparison')
    end

    def self.group_operators
      operators_by_type('group')
    end

    def self.operator_text(symbol)
      Rails.configuration.custom.search_operators.find{|o| o[:symbol] == symbol}[:text]
    end

    def pretty_operator
      self.class.operator_text(operator)
    end
  end
end
