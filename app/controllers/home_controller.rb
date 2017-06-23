class HomeController < ApplicationController
  def index
     @posts = Post.includes(:user, :location).order("created_at DESC").paginate(page: params[:page])
  end
end
