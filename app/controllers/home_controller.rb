class HomeController < ApplicationController
  def index
     @posts = Post.includes(:user, :location).order("created_at DESC").paginate(page: params[:page])

     track_day = (params[:date] || Time.now.in_time_zone("Singapore"))&.to_date
     @current_date = track_day
     gon.watch.tracks = Track.includes(:location).
                              where("DATE(created_at AT TIME ZONE 'UTC' AT TIME ZONE ?) = ?",
                                Time.now.in_time_zone("Singapore").strftime("%Z"), track_day).
                              as_json(include: [:location])
  end
end
