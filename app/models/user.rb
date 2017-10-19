class User < ApplicationRecord
  acts_as_token_authenticatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :posts
  has_many :tracks
  has_many :trips

  validates :username, presence: true

  def last_trip
    self.trips.last
  end

  def end_last_trip
    last_trip.end_trip if last_trip.present?
  end
end
