class MoreUserLoginOptions < ActiveRecord::Migration
  def change
    rename_column :users, :fb_user_picture, :profile_picture
    add_column    :users, :password_hash, :string
    add_column    :users, :password_salt, :string


    create_table :remember_logins do |t|
      t.string     :remember_token
      t.references :user
      t.timestamps
    end
    add_index :remember_logins, :remember_token
    add_index :remember_logins, :user_id


    create_table :reset_password_tokens do |t|
      t.string     :reset_token
      t.references :user
      t.timestamps
    end
    add_index :reset_password_tokens, :reset_token
    add_index :reset_password_tokens, :user_id
  end
end
