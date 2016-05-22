class Admin::CommentsController < Admin::AdminController
  before_action :find_commentable
  before_action :set_comments

  def index
    @comment  = @commentable.comments.build
    authorize @comment

    respond_to do |format|
      format.js { render :index, layout: false }
    end
  end

  def create
    comment  = @commentable.comments.build(comment_params)
    comment.user = current_user
    authorize comment

    if comment.save
      flash['notice'] = 'Saved'
      @comment = @commentable.comments.build
    else
      flash['error'] = comment.errors.full_messages
      @comment = comment
    end

    respond_to do |format|
      format.js { render :index, layout: false }
    end
  end

  def destroy
    comment  = Comment.find(params[:id])
    authorize comment
    comment.destroy

    respond_to do |format|
      @comment = @commentable.comments.build
      format.js { render :index, layout: false }
    end
  end

  private
    # http://railscasts.com/episodes/154-polymorphic-association?view=asciicast
    def find_commentable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          @commentable = $1.classify.constantize.find(value)
        end
      end
      nil
    end

    def set_comments
      @comments = policy_scope(@commentable.comments)
    end

    def comment_params
      params.require(:comment).permit(:content)
    end
end