module LikesHelper

  def user_like(micropost)
    current_user.likes.find_by(micropost: micropost)
  end

end
