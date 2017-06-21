class Api::V1::PostsController < Api::V1::BaseController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    @posts = Post.includes(:user, :location).
                  order("created_at desc").
                  paginate(page: page, per_page: page_size)

    total = @posts.total_pages
    current = @posts.current_page

    render json: {
                    posts: @posts,
                    pagination: {
                      page: [current, total].min,
                      per_page: page_size.to_i,
                      total: total
                    } 
                  }, status: :ok
  end

  def show
  end

  def edit
  end

  def create
    @post = current_user.posts.build(post_params)
    if params[:lat].present? && params[:lng].present?
      lat = to_decimal(params[:lat])
      lng = to_decimal(params[:lng])
      @location = Location.where(lat: lat, lng: lng).first

      unless @location.present?
        @location = Location.create({lat: lat, lng: lng})
      end
       @post.location = @location
    end

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
      params.require(:post).permit(:body, :lat, :lng, :per_page, :page)
    end

    def to_decimal(float)
      float.to_d.round(5)
    end

    def page_size
      params[:per_page] || 20
    end

    def page
      params[:page] || 1
    end
end
