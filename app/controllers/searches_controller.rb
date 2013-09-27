class SearchesController < ApplicationController
 def index
   @searches = Search.all
 end

 def new
   @search = Search.new
   @surveys = Survey.all
 end
 def create
   @search = Search.new(search_params)
   if @search.save
   else
     flash[:error] = @search.errors.full_messages.to_sentence
   end
   render :show
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
 def destroy
   @search = Search.find(params[:id])
 end

 def search_params
   params.require(:search).permit(:connector).tap do |whitelisted|
       whitelisted[:parameters] = params[:search][:parameters]
   end
 end
end

