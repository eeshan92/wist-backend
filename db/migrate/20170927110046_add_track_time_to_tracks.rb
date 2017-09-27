class AddTrackTimeToTracks < ActiveRecord::Migration[5.0]
  def change
    add_column :tracks, :track_time, :datetime
  end
end
