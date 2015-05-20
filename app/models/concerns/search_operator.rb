require 'active_support/concern'

module SearchOperator
  extend ActiveSupport::Concern
  NUMERIC_OPERATOR_TYPE = 'number'.freeze
  GROUP_OPERATOR_TYPE   = 'group'.freeze
  LIST_OPERATOR_TYPE    = 'list'.freeze
  TEXT_OPERATOR_TYPE    = 'text'.freeze

  included do
    def self.operators_by_type(operator_type)
      Rails.configuration.custom.search_operators.select{|o| o[:operator_type] == operator_type}
    end

    def self.numeric_operators
      operators_by_type(NUMERIC_OPERATOR_TYPE)
    end

    def self.group_operators
      operators_by_type(GROUP_OPERATOR_TYPE)
    end

    def self.list_operators
      operators_by_type(LIST_OPERATOR_TYPE)
    end

    def self.text_operators
      operators_by_type(TEXT_OPERATOR_TYPE)
    end

    def self.operator_text(symbol, operator_type)
      Rails.configuration.custom.search_operators.find{|o| o[:symbol] == symbol && o[:operator_type] == operator_type }[:text]
    end

    def pretty_operator_by_type(operator_type)
      self.class.operator_text(operator, operator_type)
    end
  end
end
