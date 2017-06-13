class Post < ApplicationRecord
  belongs_to :user
  belongs_to :location

  validates :body, :user_id, :presence => true

  def as_json(options={})
      super(:include => {
              :user => {
                :only => [:username]
              },
              :location => {
                :only => [:lat, :lng]
              }
            }
      )
    end
end
