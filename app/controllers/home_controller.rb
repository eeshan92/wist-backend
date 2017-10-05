require 'csv'

class HomeController < ApplicationController
  def index
    @posts = Post.includes(:user, :location).order("created_at DESC").paginate(page: params[:page])

    track_day = (params[:date] || Time.now.in_time_zone("Singapore")).to_date
    @current_date = track_day
    @tracks = Track.includes(:location).
              where("DATE(created_at AT TIME ZONE 'UTC' AT TIME ZONE ?) = ?",
                Time.now.in_time_zone("Singapore").strftime("%Z"), track_day)
    @tracks = @tracks.where(user_id: params[:id]) if params[:id].present?
    gon.watch.tracks = @tracks.as_json(include: [:location])

    respond_to do |format|
      format.html
      format.csv { send_file(form_csv(process_tracks)) }
      format.json { render json: process_tracks }
    end
  end

  private

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

    def form_csv(processed_tracks)
      now = Time.now
      path = File.join(Rails.root, "tracks", "report_ending_#{now}.csv")
      File.delete(path) if File.exist?(path)

      CSV.open(path, "w") do |csv|
        csv << ["id", "lat", "lng", "time", "distance", "speed", "time_diff", "user"]
        processed_tracks.each_with_index.
          reject { |t, index| (index > 0 && t["speed"] > 25.0) }.
          pluck(0).
          each do |track|
            csv << [
              track["id"],
              track["lat"].to_s,
              track["lng"],
              track["time"],
              track["distance"],
              track["speed"],
              track["time_diff"],
              track["user"]
            ]
          end
      end

      File.join(Rails.root, "tracks", "report_ending_#{now}.csv")
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
