class Admin::RelationshipsController < Admin::AdminController
  before_action :set_relationship, only: [:edit, :update, :destroy]

  def new
    @participant  = Participant.find(params[:participant_id])
    @relationship = @participant.origin_relationships.new
    authorize @relationship
  end

  def create
    @relationship = Relationship.new(relationship_params)
    authorize @relationship

    @participant = @relationship.origin
    if @relationship.save
      redirect_to admin_participant_path(@participant)
    else
      flash['error'] = @relationship.errors.full_messages.to_sentence
      redirect_to new_admin_relationship_path(participant_id: @participant.id)
    end
  end

  def edit
    authorize @relationship
    @participant = @relationship.origin
  end

  def update
    authorize @relationship

    @participant = @relationship.origin
    @relationship.update_attributes(relationship_params)
    if @relationship.save
      redirect_to admin_participant_path(@participant)
    else
      flash['error'] = @relationship.errors.full_messages.to_sentence
      redirect_to edit_admin_relationship_path(@relationship)
    end
  end

  def destroy
    authorize @relationship
    @participant = @relationship.origin
    @relationship.destroy
    redirect_to admin_participant_path(@participant)
  end

  private
    def set_relationship
      @relationship = Relationship.find(params[:id])
    end

    def relationship_params
      params.require(:relationship).permit(:origin_id,:destination_id,:notes,:category)
    end
end