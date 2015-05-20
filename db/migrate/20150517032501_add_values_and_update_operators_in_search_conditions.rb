class AddValuesAndUpdateOperatorsInSearchConditions < ActiveRecord::Migration
  def change
    add_column :search_conditions, :values, :text
    SearchCondition.all.each do |search_condition|
      unless search_condition.question.blank? || search_condition.value.blank?
        if SearchCondition.operator_type_for_question(search_condition.question) == SearchCondition::LIST_OPERATOR_TYPE
          if search_condition.operator == '='
            search_condition.operator = 'in'
          elsif search_condition.operator == '!='
            search_condition.operator = 'not in'
          end
        end
        search_condition.values = [search_condition.value]
        search_condition.save!
      end
    end
  end
end
