class Admin::ConsentsController < Admin::AdminController
  def index
    @consents = Consent.all
  end

  def new
    @consent = Consent.new
    authorize! :new, @consent
  end
  
  def create
    @consent = Consent.new(consent_params)
    authorize! :create, @consent
    if @consent.save
      flash[:notice] = "Created"
    else
      flash[:error] = @consent.errors.full_messages.to_sentence
    end
    redirect_to admin_consents_path
  end

  def show
    @consent = Consent.find(params[:id])
    authorize! :show, @consent
  end

  def edit
    @consent = Consent.find(params[:id])
    authorize! :edit, @consent
  end

  def update
    @consent = Consent.find(params[:id])
    authorize! :update, @consent
    @consent.update_attributes(consent_params)
    if @consent.save
      flash[:notice] = "Updated"
    else
      flash[:error] = @consent.errors.full_messages.to_sentence
    end
    redirect_to admin_consents_path
  end

  def deactivate
    @consent = Consent.find(params[:id])
    authorize! :deactivate, @consent
    @consent.state="inactive"
    if @consent.save
      flash[:notice] = "Activated"
    else
      flash[:error] = @consent.errors.full_messages.to_sentence
    end
    redirect_to admin_consents_path
  end
  def activate
    @consent = Consent.find(params[:id])
    authorize! :activate, @consent
    @consent.state="active"
    if @consent.save
      flash[:notice] = "Dectivated"
    else
      flash[:error] = @consent.errors.full_messages.to_sentence
    end
    redirect_to admin_consents_path
  end

  def destroy
    @consent = Consent.find(params[:id])
    authorize! :destroy, @consent
    @consent.destroy
    redirect_to admin_consents_path
  end

  def consent_params
    params.require(:consent).permit(:content, :state,:accept_text, :decline_text, :consent_type)
  end
end
