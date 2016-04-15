class Admin::RelationshipsController < Admin::AdminController
  def index
    @participant = Participant.find(params[:participant_id])
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def new
    @participant = Participant.find(params[:participant_id])
    @relationship = @participant.origin_relationships.new
    authorize! :new, @relationship
  end

  def edit
    @relationship = Relationship.find(params[:id])
    @participant = @relationship.origin
    authorize! :edit, @relationship
  end

  def update
    @relationship = Relationship.find(params[:id])
    authorize! :update, @relationship

    @participant = @relationship.origin
    @relationship.update_attributes(relationship_params)
    if @relationship.save
      redirect_to admin_participant_path(@participant)
    else
      flash['error'] = @relationship.errors.full_messages.to_sentence
      redirect_to edit_admin_relationship_path(@relationship)
    end
  end

  def create
    @relationship = Relationship.new(relationship_params)
    authorize! :create, @relationship

    @participant = @relationship.origin
    if @relationship.save
      redirect_to admin_participant_path(@participant)
    else
      flash['error'] = @relationship.errors.full_messages.to_sentence
      redirect_to new_admin_relationship_path(participant_id: @participant.id)
    end
  end

  def destroy
    @relationship = Relationship.find(params[:id])
    @participant = @relationship.origin
    authorize! :destroy, @relationship

    @relationship.destroy
    redirect_to admin_participant_path(@participant)
  end

  def relationship_params
    params.require(:relationship).permit(:origin_id,:destination_id,:notes,:category)
  end
end