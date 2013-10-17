class AddConstrains < ActiveRecord::Migration
  def change
    # --- users ---
    reversible do |dir|
      dir.up do
        # null is allowed in email because twitter login won't provide email
        change_column :users, :name,            :string, null: false
        change_column :users, :profile_picture, :text
        remove_index  :users, :email
        add_index     :users, :email,      unique: true
        remove_index  :users, :fb_user_id
        add_index     :users, :fb_user_id, unique: true
      end
      dir.down do
        change_column :users, :name,            :string, null: true
        change_column :users, :profile_picture, :string
        remove_index  :users, :email
        add_index     :users, :email
        remove_index  :users, :fb_user_id
        add_index     :users, :fb_user_id
      end
    end


    # --- friendships ---
    reversible do |dir|
      dir.up do
        change_column :friendships, :user_id,   :integer, null: false
        change_column :friendships, :friend_id, :integer, null: false
        change_column :friendships, :status,    :integer, null: false
      end
      dir.down do
        change_column :friendships, :user_id,   :integer, null: true
        change_column :friendships, :friend_id, :integer, null: true
        change_column :friendships, :status,    :integer, null: true
      end
    end


    # --- projects ---
    reversible do |dir|
      dir.up do
        change_column :projects, :owner_id, :integer, null: false
        change_column :projects, :title,    :string,  null: false, default: 'Untitled map'
      end
      dir.down do
        change_column :projects, :owner_id, :integer, null: true
        change_column :projects, :title,    :string,  null: true
        change_column_default :projects, :title, nil
        Project.connection.execute 'ALTER TABLE projects ALTER COLUMN title DROP DEFAULT'
      end
    end


    # --- places ---
    reversible do |dir|
      dir.up do
        change_column :places, :coord,      :string,  null: false
        change_column :places, :order,      :integer, null: false, default: 0
        change_column :places, :project_id, :integer, null: false
      end
      dir.down do
        change_column :places, :coord,      :string,  null: true
        change_column :places, :order,      :integer, null: true
        change_column_default :places, :order, nil
        Project.connection.execute 'ALTER TABLE places ALTER COLUMN "order" DROP DEFAULT'
        change_column :places, :project_id, :integer, null: true
      end
    end


    # --- project_participations ---
    reversible do |dir|
      dir.up do
        change_column :project_participations, :project_id, :integer, null: false
        change_column :project_participations, :user_id,    :integer, null: false
        change_column :project_participations, :status,     :integer, null: false, default: 0
      end
      dir.down do
        change_column :project_participations, :project_id, :integer, null: true
        change_column :project_participations, :user_id,    :integer, null: true
        change_column :project_participations, :status,     :integer, null: true
        change_column_default :project_participations, :status, nil
        Project.connection.execute 'ALTER TABLE project_participations ALTER COLUMN status DROP DEFAULT'
      end
    end


    # --- remember_logins ---
    reversible do |dir|
      dir.up do
        change_column :remember_logins, :remember_token, :string,  null: false
        change_column :remember_logins, :user_id,        :integer, null: false
        add_index     :remember_logins, [:remember_token, :user_id], unique: true
      end
      dir.down do
        change_column :remember_logins, :remember_token, :string,  null: true
        change_column :remember_logins, :user_id,        :integer, null: true
        remove_index  :remember_logins, [:remember_token, :user_id]
      end
    end


    # --- reset_password_tokens ---
    reversible do |dir|
      dir.up do
        change_column :reset_password_tokens, :reset_token, :string, null: false
        change_column :reset_password_tokens, :user_id,     :string, null: false
        remove_index  :reset_password_tokens, :reset_token
        add_index     :reset_password_tokens, :reset_token, unique: true
      end
      dir.down do
        change_column :reset_password_tokens, :reset_token, :string, null: true
        change_column :reset_password_tokens, :user_id,     :string, null: true
        remove_index  :reset_password_tokens, :reset_token
        add_index     :reset_password_tokens, :reset_token
      end
    end

  end
end
