class Admin::SearchesController < Admin::AdminController
  include EmailNotifications

  before_action :set_search, only: [:edit, :show, :update, :destroy, :request_data, :release_data, :return_data, :approve_return, :extend_release]
  before_action :set_studies, only: [:new, :edit, :show, :release_data ]

  def index
    authorize Search
    searches = policy_scope(Search)

    @state = params[:state]
    case @state
    when 'data_requested'
      @searches = searches.requested
      @header   = 'Requests submitted'
    when 'data_released'
      @searches = searches.all_released
      @header   = 'Requests released'
    when 'data_expiring'
      @searches = searches.expiring
      @header   = 'Requests expiring'
    else
      @searches = searches
      @header   = 'All Requests for Participants'
    end
  end

  def new
    @search = Search.new
    authorize @search
  end

  def create
    @search = Search.new(search_params)
    if params[:source_search]
      @source_search = Search.find(params[:source_search])
      authorize @source_search, :copy?
      @search.copy(@source_search)
    end
    @search.user_id = current_user.id
    authorize @search

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
    @state  = params[:state]

    participants        = @search.new? ? @search.result : @search.search_participants.map(&:participant)
    @participants       = participants if policy(@search).view_results?
    @participants_count = participants.size

    if @search.results_available?
      @search_participants_released     = @search.search_participants.released
      @search_participants_returned     = @search_participants_released.returned
      @search_participants_not_returned = @search_participants_released.where.not(id: @search_participants_returned.pluck(:id))
      @search_participants_extendable   = @search_participants_returned.extendable
    end

    @comments = @search.comments
    @comment  = @search.comments.build
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
    @search.request_data
    if @search.save
      flash['notice'] = 'Data Request Submitted'
    else
      flash['error'] = @search.errors.full_messages.to_sentence
    end
    redirect_to admin_search_path(@search)
  end

  def release_data
    authorize @search
    @search.release_data(nil, release_data_params)
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
    redirect_to admin_search_path(@search)
  end

  def return_data
    authorize @search
    @search.process_return(return_data_params)
    if @search.save
      flash['notice'] = 'Participants return status updated.'
    else
      flash['error'] = @search.errors.full_messages.to_sentence
    end
    redirect_to admin_search_path(@search, state: params[:state])
  end

  def approve_return
    authorize @search
    errors = []
    notices = []

    if params[:participant_ids]
      authorize @search, :extend_release?
      @new_search = Search.new(extend_release_search_params)
      @new_search.user_id = current_user.id
      @new_search.study   = @search.study

      options = extend_release_params.merge({ source_search: @search })
      @new_search.process_release_extention(options)
      @new_search.save

      if @new_search.errors.any?
        errors << @new_search.errors.full_messages.to_sentence
      else
        notices << %Q[ Data Request Extended:  #{view_context.link_to(@new_search.name, admin_search_path(@new_search))}]
      end
    end
    unless @new_search && @new_search.errors.any?
      @search.process_return_approval
      if @search.save
        notices << 'Return approved'
      else
        errors << @search.errors.full_messages.to_sentence
      end
    end
    flash['notice'] = notices.join('. ').html_safe if notices.any?
    flash['error']  = errors.join('. ').html_safe  if errors.any?

    redirect_to admin_search_path(@search, state: 'returned')
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

    def release_data_params
      params.require(:id)
      params.require(:participant_ids)
      params.require(:start_date)
      params.require(:end_date)
      params.permit(:id, :start_date, :warning_date, :end_date, participant_ids: [])
    end

    def return_data_params
      params.require(:id)
      params.require(:study_involvement_status)
      params.require(:study_involvement_ids)
      params.permit(:study_involvement_status, :id, study_involvement_ids: [])
    end

    def extend_release_search_params
      params.require(:search).permit(:name, :start_date, :warning_date, :end_date)
    end

    def extend_release_params
      params.require(:participant_ids)
      params.permit(participant_ids: [])
    end
end

