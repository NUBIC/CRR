class Admin::SearchesController < ApplicationController
  include Aker::Rails::SecuredController
  def index
    @searches = params[:state].blank? ? Search.all : Search.send(params[:state].to_sym) 
  end

 def new
   @search = Search.new
   @surveys = Survey.all
 end
 def create
   @search = Search.new(search_params)
   if @search.save
     redirect_to admin_search_path(@search)
   else
     flash[:error] = @search.errors.full_messages.to_sentence
     redirect_to new_admin_search_path
   end
 end

 def show
   @search = Search.find(params[:id])
 end

 def update
   @search = Search.find(params[:id])
   @search.update_attributes(search_params)
   if @search.save
     flash[:notice] = "Updated"
   else
     flash[:error] = @search.errors.full_messages.to_sentence
   end
   render :show
 end

 def request_data
   @search = Search.find(params[:id])
   @search.request_data
   if @search.save
     flash[:notice] = "Data Request Submitted"
   else
     flash[:error] = @search.errors.full_messages.to_sentence
   end
   redirect_to admin_search_path(@search)
 end
 def release_data
   @search = Search.find(params[:id])
   @search.release_data
   if @search.save
     flash[:notice] = "Data Request Submitted"
   else
     flash[:error] = @search.errors.full_messages.to_sentence
   end
   redirect_to admin_search_path(@search)
 end
 def destroy
   @search = Search.find(params[:id])
 end

 def search_params
   params.require(:search).permit(:study_id)
 end
end

