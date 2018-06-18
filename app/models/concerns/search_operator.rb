require 'active_support/concern'
require './lib/enum/operator'

module SearchOperator
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
    extend ClassMethods
  end

  module CommonMethods
    def list_operator_type
      Enum::Operator::LIST_OPERATOR_TYPE
    end

    def group_operator_type
      Enum::Operator::GROUP_OPERATOR_TYPE
    end

    def text_operator_type
      Enum::Operator::TEXT_OPERATOR_TYPE
    end

    def numeric_operator_type
      Enum::Operator::NUMERIC_OPERATOR_TYPE
    end

    def list_operator?(operator_type)
      operator_type == list_operator_type
    end

    def group_operator?(operator_type)
      operator_type == group_operator_type
    end

    def text_operator?(operator_type)
      operator_type == text_operator_type
    end

    def numeric_operator?(operator_type)
      operator_type == numeric_operator_type
    end

    def pretty_operator_by_type(operator_type)
      self.class.operator_text(operator, operator_type)
    end
  end

  module InstanceMethods
    include CommonMethods
  end

  module ClassMethods
    include CommonMethods

    def operator_list
      Enum::Operator::LIST
    end

    def operators_by_type(operator_type)
      operator_list.select{|o| o[:operator_type] == operator_type}
    end

    def list_operators
      operators_by_type(list_operator_type)
    end

    def group_operators
      operators_by_type(group_operator_type)
    end

    def text_operators
      operators_by_type(text_operator_type)
    end

    def numeric_operators
      operators_by_type(numeric_operator_type)
    end

    def operator_text(symbol, operator_type)
      operator_list.find{|o| o[:symbol] == symbol && o[:operator_type] == operator_type }[:text]
    end
  end
end
