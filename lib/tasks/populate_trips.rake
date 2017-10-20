namespace :trips do
  desc "populate attendance"
  task :populate => :environment do
    def record_trip(track, current_user)
      last_track = current_user.tracks.order("track_time asc").where("track_time < ?", track.track_time).last
      last_trip = last_track.trip if last_track.present?
      time_diff = track.track_time - last_track.track_time if last_track.present?
      current_trip = if last_track.blank?
                       puts "Adding new trip for #{current_user.id}"
                       Trip.create(user: current_user, start_time: track.track_time)
                     elsif time_diff.present? && time_diff > 3600
                       last_trip.end_trip if last_trip.present?
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
      user.tracks.
      sort { |a,b| a["track_time"] <=> b["track_time"] }.
      each do |track|
        unless track.trip.present?
          record_trip(track, user)
        end
      end
      user.trips.each { |trip| trip.end_trip }
    end

    total_added_trips = Trip.count - current_trip_count
    puts "Added #{total_added_trips} trips"
  end
end
