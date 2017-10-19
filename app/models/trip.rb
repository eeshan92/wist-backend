class Trip < ApplicationRecord
  belongs_to :user
  has_many :tracks

  enum type: { train: 0, car: 1, walk: 2, others: 3 }

  def end_trip
    self.end_time = last_track_time
    self.save!
  end

  def last_track_time
    last_track.track_time
  end

  def last_track
    self.tracks.last
  end
end
