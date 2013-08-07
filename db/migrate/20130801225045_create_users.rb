class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.text   :fb_access_token
      t.string :fb_user_id
      t.string :fb_user_picture

      t.timestamps
    end
    add_index :users, :name
    add_index :users, :email
  end
end
