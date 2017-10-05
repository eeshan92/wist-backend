class Api::V1::TracksController < Api::V1::BaseController

  def index
    render json: @tracks = Track.order("created_at desc").
                             paginate(page: params[:page] || 1)
  end

  def json
    render json: process_tracks
  end

  def create
    @track = current_user.tracks.build({"track_time" => (params[:track_time] || Time.now).to_time.in_time_zone("Singapore")})
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
      params.permit(:lat, :lng, :track_time)
    end

    def to_decimal(float)
      float.to_d.round(5)
    end

    def process_tracks
      data = Track.includes(:user, :location)
      data = data.where("created_at >= '#{params[:from]}'") if params[:from].present?

      data = data.group_by { |t| t.user.username }.
        map do |user,tracks|
          {
            user => tracks.map do |track|
              {
                "id" => track.id,
                "lat" => track.location.lat,
                "lng" => track.location.lng,
                "time" => track.track_time || track.created_at,
                "distance" => nil, # metres
                "speed" => nil, # m/s
                "time_diff" => nil, # seconds
                "user" => user.to_s
              }
            end
          }
        end.inject(:merge)

      processed = []
      (data || {}).map do |user, tracks|
        tracks.each_with_index do |track, index|
          if index > 0
            distance = calc_distance(track, tracks[index - 1])
            time_diff = track["time"] - tracks[index - 1]["time"]
            speed = (time_diff == 0 ? 999 : distance/time_diff)

            track["time_diff"] = time_diff
            track["speed"] = speed
            track["distance"] = distance
            processed << track if (time_diff < 7200 && speed < 40)
          end
        end
      end
      processed
    end

    def calc_distance loc1, loc2
      rad_per_deg = Math::PI/180  # PI / 180
      rkm = 6371                  # Earth radius in kilometers
      rm = rkm * 1000             # Radius in meters

      dlat_rad = (loc2["lat"]-loc1["lat"]) * rad_per_deg  # Delta, converted to rad
      dlon_rad = (loc2["lng"]-loc1["lng"]) * rad_per_deg

      lat1_rad, lon1_rad = [loc1["lat"] * rad_per_deg, loc1["lng"] * rad_per_deg]
      lat2_rad, lon2_rad = [loc2["lat"] * rad_per_deg, loc2["lng"] * rad_per_deg]

      a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
      c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

      rm * c # Delta in metres
    end
end
