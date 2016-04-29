class Admin::SearchesController < Admin::AdminController
  include EmailNotifications

  before_action :set_search, only: [:edit, :show, :update, :request_data, :release_data, :destroy]
  before_action :set_studies, only: [:new, :edit, :show]

  def index
    authorize Search
    @searches = params[:state] == 'data_requested' ? Search.requested : params[:state] == 'data_released' ? Search.released : Search.all.default_ordering
  end

  def new
    @search = Search.new
    authorize @search
  end

  def create
    @search         = Search.new(search_params)
    authorize @search

    @search.user_id = current_user.id

    if params[:source_search]
      @source_search = Search.find(params[:source_search])
      authorize @source_search, :show?

      @search.copy(@source_search)
    end

    if @search.save
      flash['notice'] = 'Saved'
      redirect_to admin_search_path(@search)
    else
      flash['error'] = @search.errors.full_messages.to_sentence
      redirect_to new_admin_search_path
    end
  end

  def show
    authorize @search
    @data_requested         = @search.data_requested?
    @data_released          = @search.data_released?
    @new_search             = @search.new?

    @participants           = @new_search ? @search.result : @search.search_participants.map(&:participant)
    @participants_released  = @search.released_participants if @search.data_released?
  end

  def edit
    authorize @search
  end

  def update
    authorize @search
    @search.update_attributes(search_params)
    if @search.save
      flash['notice'] = 'Updated'
    else
      flash['error'] = @search.errors.full_messages.to_sentence
    end
    redirect_to admin_search_path(@search)
  end

  def destroy
    authorize @search
    @search.destroy
    redirect_to admin_searches_path
  end

  def request_data
    authorize @search

    @search.request_data(nil,params)
    if @search.save
      flash['notice'] = 'Data Request Submitted'
    else
      flash['error'] = @search.errors.full_messages.to_sentence
    end
    redirect_to admin_search_path(@search)
  end

  def release_data
    authorize @search

    @search.release_data(nil,params)
    if @search.save
      flash['notice'] = 'Participant Data Released.'
      email = EmailNotification.active.batch_released
      user_emails = @search.user_emails
      if email && user_emails
        outbound_email(@search.user_emails, email.content, email.subject)
        flash['notice'] << ' Researcher had been notified of data release.'
      else
        flash['error'] = 'ATTENTION: Notification email message could not be sent (corresponding email could have been deactivated or emails for assosiated users are not available)'
      end
    else
      flash['error'] = @search.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.html { redirect_to admin_searches_path }
      format.js { render js: "window.location.href = '#{admin_search_path(@search)}'" }
    end
  end

  private
    def set_search
      @search = Search.find(params[:id])
    end

    def set_studies
      if current_user.admin?
        @studies = Study.active
      else
        @studies = current_user.studies.active
      end
    end

    def search_params
      params.require(:search).permit(:study_id, :name)
    end
end

