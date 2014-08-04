class Admin::SearchesController < Admin::AdminController
  def index
    @searches = params[:state].blank? ? Search.all : Search.send(params[:state].to_sym)
  end

 def new
   @search = Search.new
   @studies = Study.active
 end

 def create
   @search = Search.new(search_params)
   @search.request_date = Time.now
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
   @search.release_data(nil,params)
    if @search.save
      flash[:notice] = "Participant Data Released"
      redirect_to admin_searches_path
    else
      flash[:error] = @search.errors.full_messages.to_sentence
      redirect_to admin_search_path(@search)
    end
 end
 def destroy
    @search = Search.find(params[:id])
    authorize! :destroy, @search
    @search.destroy
    redirect_to admin_searches_path
 end

 def search_params
   params.require(:search).permit(:study_id, :name, :user_id)
 end
end

