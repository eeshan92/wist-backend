class AddLocationToPost < ActiveRecord::Migration[5.0]
  def change
    add_reference :posts, :location, index: true
  end
end
