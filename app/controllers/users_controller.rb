class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @posts = @user.posts.ordered_by_most_recent
  end

  def request_friendship
    current_user.send_invitation(params[:requested_id])
    redirect_to users_path
  end

  def pending_invitations
    @invitations = current_user.pending_invitations
    render 'pending_invitations'
  end
end
