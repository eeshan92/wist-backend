class AddTripReferenceToTrack < ActiveRecord::Migration[5.0]
  def change
    add_reference :tracks, :trip, foreign_key: true
  end
end
