class CreateTrips < ActiveRecord::Migration[5.0]
  def change
    create_table :trips do |t|
      t.integer :type
      t.datetime :start_time
      t.datetime :end_time
      t.references :user

      t.timestamps
    end
  end
end
