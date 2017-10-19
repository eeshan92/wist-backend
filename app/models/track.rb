class Track < ApplicationRecord
  include Filterable

  belongs_to :user
  belongs_to :location
  belongs_to :trip
  validates_presence_of :user_id, :location_id

  def current_trip
    self.trip
  end

  def trip_ended?
    return unless current_trip.present?
    current_trip.tracks_trips.where(type: 2).present?
  end

  def self.last_user_track(current_user)
    current_user.tracks.last(2).first
  end
end
