class Api::V1::TracksController < Api::V1::BaseController

  def create
    @track = current_user.tracks.build({})
    if params[:lat].present? && params[:lng].present?
      lat = to_decimal(params[:lat])
      lng = to_decimal(params[:lng])
      @location = Location.where(lat: lat, lng: lng).first

      unless @location.present?
        @location = Location.create({lat: lat, lng: lng})
      end
       @track.location = @location
    end

    if @track.save
      render json: { id: @track.id }, status: :ok
    else
      render json: { errors: @track.errors }, status: :unprocessable_entity
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def track_params
      params.permit(:lat, :lng)
    end

    def to_decimal(float)
      float.to_d.round(5)
    end
end