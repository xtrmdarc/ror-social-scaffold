class CreateFriendships < ActiveRecord::Migration[5.2]
  def change
    create_table :friendships do |t|
      t.integer :requester_id
      t.integer :requested_id
      t.integer :status

      t.timestamps
    end
  end
end
