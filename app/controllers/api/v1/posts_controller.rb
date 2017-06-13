class Api::V1::PostsController < Api::V1::BaseController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    @posts = Post.all

    render json: @posts.to_json, status: :ok
  end

  def show
  end

  def edit
  end

  def create
    @location = Location.where(lat: params[:lat], lng: params[:lng])
    unless @location.present?
      Location.create({lat: params[:lat], lng: params[:lng]})
    end
    @post = current_user.posts.build(post_params)

    if @post.save
      render json: { id: @post.id }, status: :ok
    else
      render json: { errors: @post.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      render json: { id: @post.id }, status: :ok
    else
      render json: { errors: @post.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:body, :lat, :lng)
    end
end
