module Enum
  module Operator
    NUMERIC_OPERATOR_TYPE = 'number'.freeze
    GROUP_OPERATOR_TYPE   = 'group'.freeze
    LIST_OPERATOR_TYPE    = 'list'.freeze
    TEXT_OPERATOR_TYPE    = 'text'.freeze

    LIST = [
      {
        unique_identifier:  'is_equal_to',
        text:               'equal to',
        symbol:             '=',
        operator_type:      NUMERIC_OPERATOR_TYPE
      },
      {
        unique_identifier:  'is_not_equal_to',
        text:               'not equal to',
        symbol:             '!=',
        operator_type:      NUMERIC_OPERATOR_TYPE
      },
      {
        unique_identifier:  'is_greater_than',
        text:               'greater than',
        symbol:             '>',
        operator_type:      NUMERIC_OPERATOR_TYPE
      },
      {
        unique_identifier:  'is_less_than',
        text:               'less than',
        symbol:             '<',
        operator_type:      NUMERIC_OPERATOR_TYPE
      },
      {
        unique_identifier:  'is_greater_than_or_equal_to',
        text:               'greater than or equal to',
        symbol:             '>=',
        operator_type:      NUMERIC_OPERATOR_TYPE
      },
      {
        unique_identifier:  'is_less_than_or_equal_to',
        text:               'less than or equal to',
        symbol:             '<=',
        operator_type:      NUMERIC_OPERATOR_TYPE
      },
      {
        unique_identifier:  'is_between',
        text:               'between (smaller value first)',
        symbol:             'between',
        cardinality:        2,
        operator_type:      NUMERIC_OPERATOR_TYPE
      },
      {
        unique_identifier:  'or',
        text:               'OR',
        symbol:             '|',
        operator_type:      GROUP_OPERATOR_TYPE
      },
      {
        unique_identifier:  'and',
        text:               'AND',
        symbol:             '&',
        operator_type:      GROUP_OPERATOR_TYPE
      },
      {
        unique_identifier:  'is_one_of',
        text:               'is',
        symbol:             'in',
        operator_type:      LIST_OPERATOR_TYPE
      },
      {
        unique_identifier:  'is_not_one_of',
        text:               'is not',
        symbol:             'not in',
        operator_type:      LIST_OPERATOR_TYPE
      },
      {
        unique_identifier:  'text_is_equal_to',
        text:               'is equal to',
        symbol:             '=',
        operator_type:      TEXT_OPERATOR_TYPE
      },
      {
        unique_identifier:  'text_is_not_equal_to',
        text:               'is not equal to',
        symbol:             '!=',
        operator_type:      TEXT_OPERATOR_TYPE
      }
    ].freeze
  end
end