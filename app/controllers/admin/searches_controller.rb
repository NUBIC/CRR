class Admin::SearchesController < Admin::AdminController
  before_filter :set_search, only: [:edit, :show, :update, :request_data, :release_data, :destroy]

  def index
    @searches = params[:state] == "data_requested" ? Search.requested : params[:state] == "data_released" ? Search.released : Search.all.default_ordering
  end

  def new
    @search = Search.new
    if current_user.admin?
      @studies = Study.active
    else
      @studies = current_user.studies.active
    end
  end

  def create
    @search         = Search.new(search_params)
    @search.user_id = current_user.ar_user.id

    if @search.save
      redirect_to admin_search_path(@search)
    else
      flash[:error] = @search.errors.full_messages.to_sentence
      redirect_to new_admin_search_path
    end
  end

  def show
    @data_requested       = @search.data_requested?
    @data_released        = @search.data_released?
    @new_search           = @search.new?

    @participants           = @new_search ? @search.result : @search.search_participants.map(&:participant)
    @participants_released  = @search.released_participants if @search.data_released?
  end

  def update
    @search.update_attributes(search_params)
    if @search.save
      flash[:notice] = "Updated"
    else
      flash[:error] = @search.errors.full_messages.to_sentence
    end
    render :show
  end

  def request_data
    @search.request_data(nil,params)
    if @search.save
      flash[:notice] = "Data Request Submitted"
    else
      flash[:error] = @search.errors.full_messages.to_sentence
    end
    redirect_to admin_search_path(@search)
  end

  def release_data
    @search.release_data(nil,params)
    if @search.save
      flash[:notice] = "Participant Data Released"
    else
      flash[:error] = @search.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.html {redirect_to admin_searches_path}
      format.js { render :js => "window.location.href = '#{admin_search_path(@search)}'" }
    end
  end

  def destroy
    authorize! :destroy, @search
    @search.destroy
    redirect_to admin_searches_path
  end

  def search_params
    params.require(:search).permit(:study_id, :name)
  end

  private
    def set_search
      @search = Search.find(params[:id])
    end
end

