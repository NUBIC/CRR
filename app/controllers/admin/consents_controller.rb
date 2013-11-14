class Admin::ConsentsController < Admin::AdminController
  def index
    @consents = Consent.all
  end

  def new
    @consent = Consent.new
  end
  
  def create
    @consent = Consent.new(consent_params)
    if @consent.save
      flash[:notice] = "Created"
    else
      flash[:error] = @consent.errors.full_messages.to_sentence
    end
    redirect_to admin_consents_path
  end

  def edit
    @consent = Consent.find(params[:id])
  end

  def update
    @consent = Consent.find(params[:id])
    @consent.update_attributes(consent_params)
    if @consent.save
      flash[:notice] = "Updated"
    else
      flash[:error] = @consent.errors.full_messages.to_sentence
    end
    redirect_to admin_consents_path
  end

  def consent_params
    params.require(:consent).permit(:content, :accept_text, :decline_text, :consent_type)
  end
end
