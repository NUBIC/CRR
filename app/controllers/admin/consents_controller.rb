class Admin::ConsentsController < Admin::AdminController
  before_action :set_consent, only: [:show, :edit, :update, :destroy, :activate, :deactivate]

  def index
    @consents = Consent.all
    authorize Consent
  end

  def new
    @consent = Consent.new
    authorize @consent
  end

  def create
    @consent = Consent.new(consent_params)
    authorize @consent
    if @consent.save
      flash['notice'] = 'Created'
    else
      flash['error'] = @consent.errors.full_messages.to_sentence
    end
    redirect_to admin_consents_path
  end

  def show
    authorize @consent
  end

  def edit
    authorize @consent
  end

  def update
    authorize @consent
    @consent.update_attributes(consent_params)
    if @consent.save
      flash['notice'] = 'Updated'
    else
      flash['error'] = @consent.errors.full_messages.to_sentence
    end
    redirect_to admin_consents_path
  end

  def destroy
    authorize @consent
    @consent.destroy
    redirect_to admin_consents_path
  end

  def deactivate
    authorize @consent
    @consent.deactivate
    if @consent.save
      flash['notice'] = 'Deactivated'
    else
      flash['error'] = @consent.errors.full_messages.to_sentence
    end
    redirect_to admin_consents_path
  end

  def activate
    authorize @consent
    @consent.activate
    if @consent.save
      flash['notice'] = 'Activated'
    else
      flash['error'] = @consent.errors.full_messages.to_sentence
    end
    redirect_to admin_consents_path
  end

  private
    def set_consent
      @consent = Consent.find(params[:id])
    end

    def consent_params
      params.require(:consent).permit(:content, :state,:accept_text, :decline_text, :consent_type, :comment)
    end
end
