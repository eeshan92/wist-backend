class Track < ApplicationRecord
  include Filterable

  belongs_to :user
  belongs_to :location
  validates_presence_of :user_id, :location_id
end
