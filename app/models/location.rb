class Location < ApplicationRecord
  validates :lat, :lng, :presence => true
  has_many :posts
  has_many :tracks
end
