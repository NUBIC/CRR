class CleanupSearchConditionsAndGroups < ActiveRecord::Migration
  def change
    SearchConditionGroup.all.each do |search_condition_group|
      search_condition_group.destroy if search_condition_group.search.nil? && search_condition_group.search_condition_group.nil?
    end

    SearchCondition.all.each do |search_condition|
      search_condition.destroy if search_condition.search_condition_group.nil?
    end
  end
end
