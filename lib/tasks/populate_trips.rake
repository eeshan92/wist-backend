namespace :trips do
  desc "populate attendance"
  task :populate => :environment do
    def record_trip(track, current_user)
      last_track = current_user.tracks.where("id < ?", track.id).last
      time_diff = track.track_time - last_track.track_time if last_track.present?
      current_trip = if time_diff.present? && time_diff > 3600
                       current_user.end_last_trip
                       puts "Adding new trip for #{current_user.id}"
                       Trip.create(user: current_user, start_time: track.track_time)
                     else
                       current_user.last_trip
                     end
      track.trip = current_trip
      track.save!
    end

    current_trip_count = Trip.count

    User.all.each do |user|
      user.tracks.each do |track|
        unless track.trip.present?
          record_trip(track, user)
        end
      end
    end

    total_added_trips = Trip.count - current_trip_count
    puts "Added #{total_added_trips} trips"
  end
end
