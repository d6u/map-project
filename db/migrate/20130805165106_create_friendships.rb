class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.references :user,   index: true
      t.references :friend, index: true
      t.integer    :status, :default => 0
      t.text       :comments

      t.timestamps
    end
    add_index :friendships, :status
  end
end
