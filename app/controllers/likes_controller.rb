class LikesController < ApplicationController

  def create
    @like = current_user.likes.new(like_params)
    @micropost = Micropost.find like_params[:micropost_id]
    if !@like.save
      flash[:notice] = @like.errors.full_messages.to_sentence
   else
      respond_to do |format|
        format.html { redirect_to @like.micropost }
        format.turbo_stream
      end
    end
  end


  def destroy
    @like = current_user.likes.find(params[:id])
    @like.destroy

    respond_to do |format|
      format.html { redirect_to @like.micropost }
      format.turbo_stream
    end
  end

  private

  def like_params
    params.require(:like).permit(:micropost_id)
  end
end
