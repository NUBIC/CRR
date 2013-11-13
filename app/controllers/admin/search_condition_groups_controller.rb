class Admin::SearchConditionGroupsController < ApplicationController
  include Aker::Rails::SecuredController
  def index
    @search_condition_groups = SearchConditionGroup.data_requested + SearchConditionGroup.data_released
  end

 def new
   @search_condition_group = SearchConditionGroup.new(:search_condition_group_id=>params[:search_condition_group_id])
 end
 def create
   @search_condition_group = SearchConditionGroup.new(search_condition_group_params)
   if @search_condition_group.save
   else
     flash[:error] = @search_condition_group.errors.full_messages.to_sentence
   end
   redirect_to admin_search_path(@search_condition_group.search)
 end

 def show
   @search_condition_group = SearchConditionGroup.find(params[:id])
 end

 def update
   @search_condition_group = SearchConditionGroup.find(params[:id])
   @search_condition_group.update_attributes(search_condition_group_params)
   if @search_condition_group.save
     flash[:notice] = "Updated"
   else
     flash[:error] = @search_condition_group.errors.full_messages.to_sentence
   end
   redirect_to admin_search_path(@search_condition_group.search)
 end

 def destroy
   @search_condition_group = SearchConditionGroup.find(params[:id])
   @search = @search_condition_group .search
   @search_condition_group.destroy
   redirect_to admin_search_path(@search)
 end

 def search_condition_group_params
   params.require(:search_condition_group).permit(:study_id,:operator,:search_condition_group_id)
 end
end

